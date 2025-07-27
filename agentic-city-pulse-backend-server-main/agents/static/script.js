// DOM elements
const fileInput = document.getElementById('fileInput');
const uploadBtn = document.getElementById('uploadBtn');
const clearBtn = document.getElementById('clearBtn');
const resultDiv = document.getElementById('result');
const loadingDiv = document.getElementById('loading');
const notificationDiv = document.getElementById('notification');
const textInput = document.getElementById('textInput');
const analyzeTextBtn = document.getElementById('analyzeTextBtn');
const clearTextBtn = document.getElementById('clearTextBtn');
const cityPulseQuery = document.getElementById('cityPulseQuery');
const includeReddit = document.getElementById('includeReddit');
const includeTwitter = document.getElementById('includeTwitter');
const analyzeCityPulseBtn = document.getElementById('analyzeCityPulseBtn');

// API endpoints
const API_URL = 'http://localhost:8000/api/agent/civic';
const CITY_PULSE_API_URL = 'http://localhost:8000/api/city-pulse/analyze';

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    setupFileUpload();
    setupTextInput();
    setupCityPulse();
    updateUploadButton();
    updateTextAnalyzeButton();
    updateCityPulseButton();
});

function setupFileUpload() {
    fileInput.addEventListener('change', function() {
        updateUploadButton();
        showNotification('File selected: ' + this.files[0]?.name, 'info');
    });

    uploadBtn.addEventListener('click', function() {
        if (fileInput.files.length > 0) {
            analyzeFiles();
        }
    });

    clearBtn.addEventListener('click', clearAllFiles);
}

function setupTextInput() {
    textInput.addEventListener('input', function() {
        updateTextAnalyzeButton();
    });

    analyzeTextBtn.addEventListener('click', function() {
        if (textInput.value.trim()) {
            analyzeText();
        }
    });

    clearTextBtn.addEventListener('click', clearText);
}

function updateUploadButton() {
    uploadBtn.disabled = fileInput.files.length === 0;
}

function updateTextAnalyzeButton() {
    analyzeTextBtn.disabled = !textInput.value.trim();
}

function setupCityPulse() {
    cityPulseQuery.addEventListener('input', function() {
        updateCityPulseButton();
    });

    analyzeCityPulseBtn.addEventListener('click', function() {
        if (cityPulseQuery.value.trim()) {
            analyzeCityPulse();
        }
    });
}

function updateCityPulseButton() {
    analyzeCityPulseBtn.disabled = !cityPulseQuery.value.trim();
}

function clearAllFiles() {
    fileInput.value = '';
    resultDiv.innerHTML = '';
    updateUploadButton();
    showNotification('All files cleared', 'success');
    clearText();
}

function clearText() {
    textInput.value = '';
    updateTextAnalyzeButton();
    showNotification('Text cleared', 'success');
}

async function analyzeFiles() {
    showLoading();
    
    try {
        const formData = new FormData();
        
        // Add all selected files
        for (let i = 0; i < fileInput.files.length; i++) {
            formData.append('file', fileInput.files[i]);
        }
        
        const response = await fetch(API_URL, {
            method: 'POST',
            body: formData
        });
        
        if (response.ok) {
            const result = await response.json();
            displayResult(result);
            showNotification('Analysis completed successfully!', 'success');
        } else {
            const errorText = await response.text();
            throw new Error(`HTTP ${response.status}: ${errorText}`);
        }
    } catch (error) {
        console.error('Error:', error);
        showNotification('Error: ' + error.message, 'error');
        resultDiv.innerHTML = '<div class="error">Analysis failed. Please try again.</div>';
    } finally {
        hideLoading();
    }
}

async function analyzeText() {
    showLoading();
    
    try {
        const formData = new FormData();
        formData.append('text', textInput.value.trim());
        
        const response = await fetch(API_URL, {
            method: 'POST',
            body: formData
        });
        
        if (response.ok) {
            const result = await response.json();
            displayResult(result);
            showNotification('Text analysis completed successfully!', 'success');
        } else {
            const errorText = await response.text();
            throw new Error(`HTTP ${response.status}: ${errorText}`);
        }
    } catch (error) {
        console.error('Error:', error);
        showNotification('Error: ' + error.message, 'error');
        resultDiv.innerHTML = '<div class="error">Text analysis failed. Please try again.</div>';
    } finally {
        hideLoading();
    }
}

async function analyzeCityPulse() {
    showLoading();
    
    try {
        const formData = new FormData();
        formData.append('query', cityPulseQuery.value.trim());
        formData.append('include_reddit', includeReddit.checked);
        formData.append('include_twitter', includeTwitter.checked);
        
        const response = await fetch(CITY_PULSE_API_URL, {
            method: 'POST',
            body: formData
        });
        
        if (response.ok) {
            const result = await response.json();
            displayCityPulseResult(result.result);
            showNotification('City pulse analysis completed successfully!', 'success');
        } else {
            const errorText = await response.text();
            throw new Error(`HTTP ${response.status}: ${errorText}`);
        }
    } catch (error) {
        console.error('Error:', error);
        showNotification('Error: ' + error.message, 'error');
        resultDiv.innerHTML = '<div class="error">City pulse analysis failed. Please try again.</div>';
    } finally {
        hideLoading();
    }
}

function displayResult(result) {
    resultDiv.innerHTML = '';
    
    const resultContainer = document.createElement('div');
    resultContainer.className = 'result-container';
    
    // Add input type info
    const inputInfo = document.createElement('div');
    inputInfo.className = 'input-info';
    inputInfo.innerHTML = `
        <strong>Input Type:</strong> ${result.input_type || 'Unknown'}<br>
        <strong>Analysis Type:</strong> ${result.analysis_type || 'Unknown'}<br>
        ${result.filename ? `<strong>Filename:</strong> ${result.filename}<br>` : ''}
        ${result.text_length ? `<strong>Text Length:</strong> ${result.text_length} characters<br>` : ''}
    `;
    resultContainer.appendChild(inputInfo);
    
    // Add result content
    const resultContent = document.createElement('div');
    resultContent.className = 'result-content';
    
    if (typeof result.result === 'string') {
        try {
            // Try to parse as JSON for better formatting
            const parsedResult = JSON.parse(result.result);
            resultContent.innerHTML = `<pre>${JSON.stringify(parsedResult, null, 2)}</pre>`;
        } catch (e) {
            // If not JSON, display as text
            resultContent.innerHTML = `<pre>${result.result}</pre>`;
        }
    } else {
        resultContent.innerHTML = `<pre>${JSON.stringify(result.result, null, 2)}</pre>`;
    }
    
    resultContainer.appendChild(resultContent);
    resultDiv.appendChild(resultContainer);
}

function displayCityPulseResult(result) {
    resultDiv.innerHTML = '';
    
    const resultContainer = document.createElement('div');
    resultContainer.className = 'result-container';
    
    // Add query info
    const queryInfo = document.createElement('div');
    queryInfo.className = 'input-info';
    queryInfo.innerHTML = `
        <strong>Query:</strong> ${result.query}<br>
        <strong>Timestamp:</strong> ${result.timestamp}<br>
        <strong>Summary:</strong> ${result.summary}
    `;
    resultContainer.appendChild(queryInfo);
    
    // Add Reddit data
    if (result.reddit_data && Object.keys(result.reddit_data).length > 0) {
        const redditSection = document.createElement('div');
        redditSection.className = 'result-content';
        redditSection.innerHTML = '<h3>📱 Reddit Data</h3>';
        
        for (const [subreddit, posts] of Object.entries(result.reddit_data)) {
            const subredditDiv = document.createElement('div');
            subredditDiv.innerHTML = `<h4>r/${subreddit}</h4>`;
            
            if (Array.isArray(posts)) {
                const postsList = document.createElement('ul');
                posts.forEach(post => {
                    const li = document.createElement('li');
                    li.textContent = post;
                    postsList.appendChild(li);
                });
                subredditDiv.appendChild(postsList);
            } else {
                subredditDiv.innerHTML += `<p>${posts}</p>`;
            }
            
            redditSection.appendChild(subredditDiv);
        }
        
        resultContainer.appendChild(redditSection);
    }
    
    // Add Twitter data
    if (result.twitter_data && result.twitter_data.length > 0) {
        const twitterSection = document.createElement('div');
        twitterSection.className = 'result-content';
        twitterSection.innerHTML = '<h3>🐦 Twitter Data</h3>';
        
        const tweetsList = document.createElement('div');
        result.twitter_data.forEach(tweet => {
            const tweetDiv = document.createElement('div');
            tweetDiv.className = 'tweet-item';
            tweetDiv.innerHTML = `
                <div class="tweet-header">
                    <strong>@${tweet.username}</strong>
                    <span class="tweet-date">${tweet.date}</span>
                    <span class="tweet-hashtag">${tweet.hashtag}</span>
                </div>
                <div class="tweet-content">${tweet.content}</div>
            `;
            tweetsList.appendChild(tweetDiv);
        });
        
        twitterSection.appendChild(tweetsList);
        resultContainer.appendChild(twitterSection);
    }
    
    resultDiv.appendChild(resultContainer);
}

function showLoading() {
    loadingDiv.style.display = 'block';
    uploadBtn.disabled = true;
    analyzeTextBtn.disabled = true;
    analyzeCityPulseBtn.disabled = true;
}

function hideLoading() {
    loadingDiv.style.display = 'none';
    updateUploadButton();
    updateTextAnalyzeButton();
    updateCityPulseButton();
}

function showNotification(message, type) {
    notificationDiv.textContent = message;
    notificationDiv.className = `notification ${type}`;
    notificationDiv.style.display = 'block';
    
    setTimeout(() => {
        notificationDiv.style.display = 'none';
    }, 5000);
} 