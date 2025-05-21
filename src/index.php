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
        http_response_code(400);
        error_log("Invalid request type: {$requestType}");
        echo json_encode([
            'success' => false,
            'error' => 'Invalid request type'
        ]);
        exit;
}

// Initialize the handler
$handler->init();