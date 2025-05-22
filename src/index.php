<?php

// Load all required class files
require_once __DIR__ . '/handlers/ai-agent.php';
require_once __DIR__ . '/handlers/twilio.php';
require_once __DIR__ . '/handlers/webhook.php';

// Load environment variables
if (file_exists(__DIR__ . '/.env')) {
    $lines = file(__DIR__ . '/.env', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) continue; // Ignore comments
        putenv($line);
    }
}

// Get request headers and URL path
$headers = apache_request_headers();
$requestPath = strtolower(trim(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH), '/'));

// Handle static assets
if (strpos($requestPath, 'assets/') === 0) {
    $assetPath = __DIR__ . '/' . $requestPath;
    if (file_exists($assetPath)) {
        $extension = pathinfo($assetPath, PATHINFO_EXTENSION);
        $contentTypes = [
            'css' => 'text/css',
            'js' => 'application/javascript',
            'html' => 'text/html',
            'png' => 'image/png',
            'jpg' => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'gif' => 'image/gif'
        ];
        
        if (isset($contentTypes[$extension])) {
            header('Content-Type: ' . $contentTypes[$extension]);
            header('Cache-Control: public, max-age=31536000'); // Cache for 1 year
            header('Expires: ' . gmdate('D, d M Y H:i:s \G\M\T', time() + 31536000));
            readfile($assetPath);
            exit;
        }
    }
    http_response_code(404);
    exit;
}

// Handle root URL with GET request
if (empty($requestPath) && $_SERVER['REQUEST_METHOD'] === 'GET') {
    header('Content-Type: text/html');
    include __DIR__ . '/assets/index.html';
    exit;
}

// Get request type from header or URL path
$requestType = strtolower($headers['X-Request-Type'] ?? '');
if (empty($requestType)) {
    // Extract request type from URL path
    $pathParts = explode('/', $requestPath);
    $requestType = end($pathParts); // Get the last part of the URL
}

// Route the request to appropriate handler
switch ($requestType) {
    case 'ai-agent':
        $handler = new ChatwootAgent();
        break;
    
    case 'twilio':
        $handler = new TwilioWebhook();
        break;
    
    case 'webhook':
        $handler = new ChatwootWebhook();
        break;
    
    default:
        http_response_code(404);
        header('Content-Type: application/json');
        echo json_encode([
            'success' => false,
            'error' => 'Endpoint not found',
            'message' => 'The requested endpoint does not exist',
            'path' => $requestPath
        ]);
        exit;
}

// Initialize the handler
$handler->init();