const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 4000;

// MIME types for different file extensions
const mimeTypes = {
  '.html': 'text/html',
  '.css': 'text/css',
  '.js': 'application/javascript',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon'
};

const server = http.createServer((req, res) => {
  // Parse URL and remove query parameters
  let filePath = req.url.split('?')[0];
  
  // Default to index.html for root path
  if (filePath === '/') {
    filePath = '/index.html';
  }
  
  // Serve files from web directory
  const fullPath = path.join(__dirname, 'web', filePath);
  
  // Get file extension
  const ext = path.extname(fullPath).toLowerCase();
  const contentType = mimeTypes[ext] || 'application/octet-stream';
  
  // Check if file exists
  fs.access(fullPath, fs.constants.F_OK, (err) => {
    if (err) {
      // File not found
      res.writeHead(404, { 'Content-Type': 'text/html' });
      res.end(`
        <!DOCTYPE html>
        <html>
        <head>
          <title>404 - Page Not Found</title>
          <style>
            body { font-family: Arial, sans-serif; text-align: center; padding: 50px; background: #0f172a; color: #e2e8f0; }
            h1 { color: #6366f1; }
            a { color: #6366f1; text-decoration: none; }
            a:hover { text-decoration: underline; }
          </style>
        </head>
        <body>
          <h1>404 - Page Not Found</h1>
          <p>The requested page could not be found.</p>
          <p><a href="/">Return to TournamentFlow</a></p>
        </body>
        </html>
      `);
      return;
    }
    
    // Read and serve the file
    fs.readFile(fullPath, (err, data) => {
      if (err) {
        res.writeHead(500, { 'Content-Type': 'text/html' });
        res.end(`
          <!DOCTYPE html>
          <html>
          <head>
            <title>500 - Server Error</title>
            <style>
              body { font-family: Arial, sans-serif; text-align: center; padding: 50px; background: #0f172a; color: #e2e8f0; }
              h1 { color: #ef4444; }
              a { color: #6366f1; text-decoration: none; }
              a:hover { text-decoration: underline; }
            </style>
          </head>
          <body>
            <h1>500 - Server Error</h1>
            <p>An error occurred while serving the file.</p>
            <p><a href="/">Return to TournamentFlow</a></p>
          </body>
          </html>
        `);
        return;
      }
      
      // Set appropriate headers
      res.writeHead(200, { 
        'Content-Type': contentType,
        'Cache-Control': 'no-cache'
      });
      res.end(data);
    });
  });
});

server.listen(PORT, () => {
  console.log(`🏆 TournamentFlow server running at http://localhost:${PORT}`);
  console.log(`📁 Serving files from: ${path.join(__dirname, 'web')}`);
  console.log(`🚀 Open your browser and navigate to http://localhost:${PORT}`);
  console.log(`\n📋 Available pages:`);
  console.log(`   • Home: http://localhost:${PORT}/`);
  console.log(`   • Tournaments: http://localhost:${PORT}/tournaments.html`);
  console.log(`   • Rewards: http://localhost:${PORT}/rewards.html`);
  console.log(`   • Documentation: http://localhost:${PORT}/docs.html`);
  console.log(`\n⚡ Powered by Kwala workflows for decentralized tournament automation`);
});

// Handle server shutdown gracefully
process.on('SIGINT', () => {
  console.log('\n🛑 Shutting down TournamentFlow server...');
  server.close(() => {
    console.log('✅ Server closed successfully');
    process.exit(0);
  });
});