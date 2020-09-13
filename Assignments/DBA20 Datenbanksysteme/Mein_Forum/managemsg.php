<?php
session_start();
require_once "helpers.php";

/* properly called? */
if ( !isset($_GET["thread_id"]) || !ctype_digit($_GET["thread_id"])
        || !isset($_GET["msg_id"]) || !ctype_digit($_GET["msg_id"]) ) {
    header("location: " .HOME);
    exit;
}

$msg_id = $_GET["msg_id"];
$thread_id = $_GET["thread_id"];

if (isset($_GET["del"])) {

    /* user logged-in and admin */
    $check = check_user(isset($_SESSION["id"])? $_SESSION["id"] : false);
    if (!$check['user_is_admin']) {
        header("location: " .HOMEDIR. "viewthread.php/?id=$thread_id");
        exit;
    }
    if (exec_sql("DELETE FROM msg WHERE id=?", [$msg_id], "i")) {
        exec_sql("UPDATE thread SET msg_count=msg_count-1 WHERE id=?", [$thread_id], "i");
    }
}

$mysqli->close();
header("location: " .HOMEDIR. "viewthread.php/?id=$thread_id");
exit;
?>
