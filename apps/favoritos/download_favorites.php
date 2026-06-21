<?php
header('Content-Type: application/octet-stream');
header('Content-Disposition: attachment; filename="favorites.txt"');
header('Content-Transfer-Encoding: binary');
require_once __DIR__ . '/config.php';
ensureFavoritesFile();

// Lê e envia o arquivo
readfile(FAVORITES_FILE);
?>
