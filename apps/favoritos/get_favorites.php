<?php
header('Content-Type: application/json');
require_once __DIR__ . '/config.php';
ensureFavoritesFile();

// Verificar se o arquivo de favoritos existe
if (!file_exists(FAVORITES_FILE)) {
    echo json_encode([
        'success' => true,
        'favorites' => []
    ]);
    exit;
}

// Ler o arquivo de favoritos
$content = file_get_contents(FAVORITES_FILE);
$lines = explode("\n", $content);
$favorites = [];

// Processar cada linha
foreach ($lines as $line) {
    if (trim($line) !== "") {
        $parts = explode(",", $line, 2);
        if (count($parts) === 2) {
            $favorites[] = [
                'name' => $parts[0],
                'url' => $parts[1]
            ];
        }
    }
}

// Retornar os favoritos como JSON
echo json_encode([
    'success' => true,
    'favorites' => $favorites
]);
?>
