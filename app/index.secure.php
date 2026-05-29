<?php
// ─────────────────────────────────────────────────────────────────────────
// Version CORRIGEE de l'app (remediation du writeup CTF).
// - plus de system() / shell : on utilise le client HTTP natif de PHP (curl_*)
// - whitelist du schema (http/https uniquement)
// - blocage explicite de la metadata EC2 et du loopback (anti-SSRF)
// semgrep ne doit PAS lever de RCE ici.
// ─────────────────────────────────────────────────────────────────────────

$input = isset($_POST['input']) ? $_POST['input'] : '';
$url   = filter_var($input, FILTER_VALIDATE_URL);

$host    = $url ? parse_url($url, PHP_URL_HOST) : '';
$scheme  = $url ? parse_url($url, PHP_URL_SCHEME) : '';
$blocked = in_array($host, ['169.254.169.254', '127.0.0.1', 'localhost', '::1'], true);

if ($url && in_array($scheme, ['http', 'https'], true) && !$blocked) {
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 5);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, false);
    $output = curl_exec($ch);
    curl_close($ch);
    echo htmlspecialchars($output === false ? 'erreur' : $output);
} else {
    http_response_code(400);
    echo 'URL refusee';
}
?>
<!DOCTYPE html>
<html>
<body>
<form action="index.secure.php" method="post">
Enter URL to curl :
   <input type="text" name="input" id="input">
   <input type="submit" value="Launch" name="submit">
</form>
</body>
</html>
