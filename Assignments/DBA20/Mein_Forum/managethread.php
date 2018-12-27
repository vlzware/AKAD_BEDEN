<?php
session_start();
require_once "helpers.php";

/* user logged-in and admin */
$check = check_user(isset($_SESSION["id"])? $_SESSION["id"] : false);
if (!$check['user_is_admin']) {
    header("location: " .HOME);
    exit;
}

/* delete thread */
if (isset($_GET["del"])) {
    if (exec_sql("DELETE FROM msg WHERE thread_id=?", [$_GET["id"]], "i")) {
        exec_sql("DELETE FROM thread WHERE id=?", [$_GET["id"]], "i");
    }

/* lock/unlock thread */
} elseif (isset($_GET["lock"])) {
    exec_sql("UPDATE thread SET locked=1 WHERE id=?", [$_GET["id"]], "i");
} elseif (isset($_GET["unlock"])) {
    exec_sql("UPDATE thread SET locked=0 WHERE id=?", [$_GET["id"]], "i");
}

$mysqli->close();
header("location: " .HOME);
exit;
?>
