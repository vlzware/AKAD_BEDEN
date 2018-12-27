<?php
session_start();
require_once "helpers.php";

/* only admin(s) allowed to manage accounts */
$check = check_user(isset($_SESSION["id"])? $_SESSION["id"] : false);
if (!$check['user_is_admin']) {
    header("location: " .HOME);
    exit;
}

/* properly called? */
if ( !isset($_GET["id"]) || !ctype_digit($_GET["id"]) ) {
    header("location: " .HOME);
    exit;
}

$all_ok = false;

/* admin/ no-admin */
if (isset($_GET["admin"])) {
    if (exec_sql("UPDATE user SET is_admin=1 WHERE id=?", [$_GET["id"]], "i")) {
        $all_ok = true;
    }
} elseif (isset($_GET["noadmin"])) {
    if (exec_sql("UPDATE user SET is_admin=0 WHERE id=?", [$_GET["id"]], "i")) {
        $all_ok = true;
    }

/* lock user */
} elseif (isset($_GET["lock"])) {
    if (exec_sql("UPDATE user SET locked=1 WHERE id=?", [$_GET["id"]], "i")) {
        $all_ok = true;
    }
} elseif (isset($_GET["unlock"])) {
    if (exec_sql("UPDATE user SET locked=0 WHERE id=?", [$_GET["id"]], "i")) {
        $all_ok = true;
    }

/* delete user */
} elseif (isset($_GET["del"])) {
    $sql = "UPDATE msg SET user_id=2 WHERE user_id=?";
    if (exec_sql($sql, [$_GET["id"]], "i")) {
        $sql = "UPDATE thread SET user_id=2 WHERE user_id=?";
        if (exec_sql($sql, [$_GET["id"]], "i")) {
            $sql = "DELETE FROM user WHERE id=?";
            if (exec_sql($sql, [$_GET["id"]], "i")) {
                $all_ok = true;
            }
        }
    }
}

if ($all_ok) {
    header("location: " .HOMEDIR. "users.php");
    exit;
}
?>
