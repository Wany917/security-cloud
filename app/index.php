<?php
// ─────────────────────────────────────────────────────────────────────────
// App du CTF kungfu, VOLONTAIREMENT VULNERABLE (reference).
// Sert au static testing : semgrep doit flagger la SSRF + la RCE ci-dessous.
// La version corrigee est dans index.secure.php.
// ─────────────────────────────────────────────────────────────────────────

// FILTER_VALIDATE_URL n'est PAS un filtre de securite : il valide la forme,
// pas l'innocuite. $input n'est pas quote et part dans un appel shell.
$input   = filter_var($_POST['input'], FILTER_VALIDATE_URL);
$command = "curl $input";   // injection shell possible
$output  = system($command); // RCE : execution + affichage de stdout
?>
<!DOCTYPE html>
<html>
<body>
<form action="index.php" method="post">
Enter URL to curl :
   <input type="text" name="input" id="input">
   <input type="submit" value="Launch" name="submit">
</form>
</body>
</html>
