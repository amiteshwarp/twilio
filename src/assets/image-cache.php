<?php
// Set cache headers for 3 hours
$cacheTime = 3 * 60 * 60; // 3 hours in seconds
header('Cache-Control: public, max-age=' . $cacheTime);
header('Expires: ' . gmdate('D, d M Y H:i:s \G\M\T', time() + $cacheTime));
header('Pragma: cache');

// Get image URL from query parameter
$imageUrl = $_GET['url'] ?? '';
if (empty($imageUrl)) {
    http_response_code(400);
    exit('No image URL provided');
}

// Fetch and output the image
$imageData = file_get_contents($imageUrl);
if ($imageData === false) {
    http_response_code(404);
    exit('Image not found');
}

// Set content type based on image URL
$extension = pathinfo($imageUrl, PATHINFO_EXTENSION);
$contentTypes = [
    'jpg' => 'image/jpeg',
    'jpeg' => 'image/jpeg',
    'png' => 'image/png',
    'gif' => 'image/gif'
];

if (isset($contentTypes[$extension])) {
    header('Content-Type: ' . $contentTypes[$extension]);
}

echo $imageData; 