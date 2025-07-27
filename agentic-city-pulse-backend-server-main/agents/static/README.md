# Civic Issue Analyzer - Static UI

A modern, responsive web interface for the Civic Issue Analyzer application that allows users to upload and analyze civic issues from images, text files, and audio recordings.

## Features

- **Drag & Drop File Upload**: Easy file upload with drag and drop functionality
- **Multiple File Support**: Upload and analyze multiple files at once
- **File Type Validation**: Supports JPG, PNG, TXT, WAV, MP3, and M4A files
- **Real-time Analysis**: Connect to the FastAPI backend for AI-powered analysis
- **Responsive Design**: Works on desktop, tablet, and mobile devices
- **Modern UI**: Clean, intuitive interface with smooth animations
- **Error Handling**: Comprehensive error handling and user feedback

## File Structure

```
static/
├── index.html          # Main HTML file
├── styles.css          # CSS styles and responsive design
├── script.js           # JavaScript functionality
└── README.md           # This file
```

## How to Use

### Prerequisites

1. Make sure your FastAPI backend is running:
   ```bash
   python api_endpoint.py
   ```

2. The backend should be accessible at `http://localhost:8000`

### Running the Static UI

1. **Using a local web server** (recommended):
   ```bash
   # Using Python's built-in server
   cd static
   python -m http.server 8080
   ```

2. **Using Node.js** (if you have it installed):
   ```bash
   # Install a simple HTTP server
   npm install -g http-server
   
   # Run the server
   cd static
   http-server -p 8080
   ```

3. **Using any web server**: Simply serve the `static` directory with any web server

### Accessing the UI

Open your web browser and navigate to:
- `http://localhost:8080` (if using Python server)
- Or whatever port your web server is using

## Usage Instructions

1. **Upload Files**:
   - Drag and drop files onto the upload area
   - Or click "Choose File" to select files manually
   - Supported formats: JPG, PNG, TXT, WAV, MP3, M4A

2. **File Management**:
   - View uploaded files in the file list
   - Remove individual files using the remove button
   - Clear all files using the "Clear All" button

3. **Analysis**:
   - Click "Analyze Files" to start the analysis
   - Wait for the processing to complete
   - View results in the results section

4. **Results**:
   - Each file's analysis is displayed in a separate card
   - Results include issue type, description, location, and other details
   - Color-coded issue types for easy identification

## Configuration

### API Endpoint

The UI is configured to connect to the FastAPI backend at `http://localhost:8000`. To change this:

1. Edit the `API_URL` constant in `script.js`:
   ```javascript
   const API_URL = 'http://your-backend-url:port/api/agent/civic';
   ```

2. Or set the `CIVIC_API_URL` environment variable when serving the files.

### File Size Limits

The default file size limit is 50MB. To change this:

1. Edit the `isValidFile` function in `script.js`:
   ```javascript
   if (file.size > 100 * 1024 * 1024) { // 100MB limit
   ```

## Supported Civic Issues

The application can detect and categorize the following civic issues:

- **Traffic Congestion**: Traffic jams and road congestion
- **Drainage Issues**: Problems with drainage systems
- **Flooding**: Water flooding in areas
- **Water Logging**: Accumulation of water
- **Road Blocks**: Obstructions on roads
- **Tree Obstructions**: Trees blocking roads or paths
- **Electricity Issues**: Power-related problems

## Browser Compatibility

- Chrome 60+
- Firefox 55+
- Safari 12+
- Edge 79+

## Troubleshooting

### Common Issues

1. **"Analysis failed" error**:
   - Check if the FastAPI backend is running
   - Verify the API endpoint URL in `script.js`
   - Check browser console for detailed error messages

2. **Files not uploading**:
   - Ensure files are in supported formats
   - Check file size limits
   - Verify browser supports File API

3. **CORS errors**:
   - The backend needs to allow CORS from your frontend domain
   - Add CORS middleware to your FastAPI app if needed

### Backend CORS Configuration

If you encounter CORS issues, add this to your FastAPI app:

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:8080"],  # Add your frontend URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## Development

### Customizing the UI

- **Colors**: Edit the CSS variables in `styles.css`
- **Layout**: Modify the HTML structure in `index.html`
- **Functionality**: Extend the JavaScript in `script.js`

### Adding New Features

1. **New File Types**: Update the `validTypes` array in `script.js`
2. **New Issue Types**: Add CSS classes in `styles.css` and update `getIssueClass()` in `script.js`
3. **Additional UI Elements**: Add HTML and corresponding CSS/JS

## License

This static UI is part of the Civic Issue Analyzer project. 