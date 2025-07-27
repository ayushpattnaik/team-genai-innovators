import os
import json
import streamlit as st
from typing import List, Dict, Any, Optional
from datetime import datetime
import google.cloud.aiplatform as aiplatform
from google.cloud import firestore
from google.auth import default
import vertexai
from vertexai.language_models import TextGenerationModel
from vertexai.generative_models import GenerativeModel
import firebase_admin
from firebase_admin import credentials, firestore as admin_firestore
from dotenv import load_dotenv

# Load environment variables
load_dotenv('hackathon/config.env')

class VertexAIFirestoreChatbot:
    def __init__(self):
        """Initialize the Vertex AI Firestore Chatbot"""
        self.project_id = os.getenv('GOOGLE_CLOUD_PROJECT_ID', 'magnetic-signer-466310-b9')
        self.location = os.getenv('GOOGLE_CLOUD_LOCATION', 'us-central1')
        self.firebase_credentials_path = os.getenv('FIREBASE_CREDENTIALS_PATH', 'service-account-firebase.json')
        
        # Initialize Firebase
        self._initialize_firebase()
        
        # Initialize Vertex AI
        self._initialize_vertex_ai()
        
        # Initialize the generative model
        self.model = GenerativeModel("gemini-2.5-flash")
        
    def _initialize_firebase(self):
        """Initialize Firebase Admin SDK"""
        try:
            if not firebase_admin._apps:
                cred = credentials.Certificate(self.firebase_credentials_path)
                firebase_admin.initialize_app(cred)
            self.db = admin_firestore.client(database_id='innovators')
            st.success("✅ Firebase initialized successfully")
        except Exception as e:
            st.error(f"❌ Firebase initialization failed: {e}")
            self.db = None
    
    def _initialize_vertex_ai(self):
        """Initialize Vertex AI with service account authentication"""
        try:
            # Load service account credentials
            from google.oauth2 import service_account
            credentials_obj = service_account.Credentials.from_service_account_file(
                self.firebase_credentials_path
            )
            
            # Initialize Vertex AI with credentials object
            vertexai.init(
                project=self.project_id, 
                location=self.location,
                credentials=credentials_obj
            )
            st.success("✅ Vertex AI initialized successfully with service account")
        except Exception as e:
            st.error(f"❌ Vertex AI initialization failed: {e}")
            # Try fallback initialization
            try:
                vertexai.init(project=self.project_id, location=self.location)
                st.success("✅ Vertex AI initialized with fallback method")
            except Exception as e2:
                st.error(f"❌ Vertex AI fallback initialization failed: {e2}")
    
    def fetch_data_from_firestore(self, collection_name: str, limit: int = 100) -> List[Dict[str, Any]]:
        """Fetch data from Firestore collection"""
        if not self.db:
            return []
        
        try:
            collection_ref = self.db.collection(collection_name)
            docs = collection_ref.limit(limit).stream()
            
            results = []
            for doc in docs:
                doc_data = doc.to_dict()
                doc_data['id'] = doc.id
                # Convert datetime objects to strings for JSON serialization
                for key, value in doc_data.items():
                    if isinstance(value, datetime):
                        doc_data[key] = value.isoformat()
                results.append(doc_data)
            
            return results
        except Exception as e:
            st.error(f"Error fetching data from Firestore: {e}")
            return []
    
    def get_collection_names(self) -> List[str]:
        """Get all collection names from Firestore"""
        if not self.db:
            return []
        
        try:
            collections = self.db.collections()
            return [collection.id for collection in collections]
        except Exception as e:
            st.error(f"Error fetching collection names: {e}")
            return []
    
    def query_data_with_ai(self, user_query: str, collection_data: List[Dict[str, Any]]) -> str:
        """Use Vertex AI to query and analyze the data"""
        if not collection_data:
            return "No data available to query."
        
        # Prepare context for the AI model
        context = f"""
        You are a helpful assistant that analyzes city pulse data. You have access to the following data from Firestore:
        
        {json.dumps(collection_data, indent=2)}
        
        User Query: {user_query}
        
        Please analyze the data and provide a comprehensive answer. If the query is about:
        - Civic issues: Look for patterns, categories, locations, and trends
        - Data statistics: Provide counts, summaries, and insights
        - Specific locations: Filter and analyze data for particular areas
        - Time-based analysis: Look at timestamps and temporal patterns
        
        Provide your response in a clear, structured format with relevant insights and data points.
        """
        
        try:
            response = self.model.generate_content(context)
            return response.text
        except Exception as e:
            return f"Error generating response: {e}"
    
    def get_data_summary(self, collection_name: str) -> Dict[str, Any]:
        """Get a summary of the data in a collection"""
        data = self.fetch_data_from_firestore(collection_name)
        
        if not data:
            return {"error": "No data found"}
        
        summary = {
            "total_records": len(data),
            "collections": collection_name,
            "sample_fields": list(data[0].keys()) if data else [],
            "data_types": {}
        }
        
        # Analyze data types
        if data:
            for key, value in data[0].items():
                summary["data_types"][key] = type(value).__name__
        
        return summary

def main():
    st.set_page_config(
        page_title="City Pulse AI Chatbot",
        page_icon="🏙️",
        layout="wide"
    )
    
    st.title("🏙️ City Pulse AI Chatbot")
    st.markdown("Query and analyze your Firestore data using Vertex AI")
    
    # Initialize the chatbot
    if 'chatbot' not in st.session_state:
        st.session_state.chatbot = VertexAIFirestoreChatbot()
    
    chatbot = st.session_state.chatbot
    
    # Sidebar for configuration
    with st.sidebar:
        st.header("🔧 Configuration")
        
        # Collection selection
        collections = chatbot.get_collection_names()
        if collections:
            selected_collection = st.selectbox(
                "Select Firestore Collection",
                collections,
                index=0 if collections else None
            )
        else:
            st.warning("No collections found in Firestore")
            selected_collection = None
        
        # Data limit
        data_limit = st.slider("Data Limit", min_value=10, max_value=500, value=100, step=10)
        
        # Load data button
        if st.button("🔄 Load Data"):
            if selected_collection:
                with st.spinner("Loading data from Firestore..."):
                    st.session_state.collection_data = chatbot.fetch_data_from_firestore(selected_collection, data_limit)
                    st.session_state.selected_collection = selected_collection
                st.success(f"Loaded {len(st.session_state.collection_data)} records from {selected_collection}")
    
    # Main content area
    col1, col2 = st.columns([1, 1])
    
    with col1:
        st.header("📊 Data Overview")
        
        if 'collection_data' in st.session_state and st.session_state.collection_data:
            data = st.session_state.collection_data
            collection_name = st.session_state.selected_collection
            
            # Display data summary
            summary = chatbot.get_data_summary(collection_name)
            
            st.metric("Total Records", summary["total_records"])
            st.metric("Collection", collection_name)
            
            # Show sample data
            st.subheader("Sample Data")
            if data:
                st.json(data[0] if len(data) > 0 else {})
            
            # Show data structure
            st.subheader("Data Structure")
            st.json(summary["data_types"])
        else:
            st.info("Select a collection and load data to see the overview")
    
    with col2:
        st.header("🤖 AI Chatbot")
        
        # Initialize chat history
        if "messages" not in st.session_state:
            st.session_state.messages = []
        
        # Display chat messages
        for message in st.session_state.messages:
            with st.chat_message(message["role"]):
                st.markdown(message["content"])
        
        # Chat input
        if prompt := st.chat_input("Ask about your data..."):
            # Add user message to chat history
            st.session_state.messages.append({"role": "user", "content": prompt})
            
            # Display user message
            with st.chat_message("user"):
                st.markdown(prompt)
            
            # Generate AI response
            with st.chat_message("assistant"):
                with st.spinner("Analyzing data..."):
                    if 'collection_data' in st.session_state and st.session_state.collection_data:
                        response = chatbot.query_data_with_ai(prompt, st.session_state.collection_data)
                    else:
                        response = "Please load data from a Firestore collection first to enable AI analysis."
                    
                    st.markdown(response)
            
            # Add assistant response to chat history
            st.session_state.messages.append({"role": "assistant", "content": response})
    
    # Clear chat button
    if st.button("🗑️ Clear Chat History"):
        st.session_state.messages = []
        st.rerun()

if __name__ == "__main__":
    main() 