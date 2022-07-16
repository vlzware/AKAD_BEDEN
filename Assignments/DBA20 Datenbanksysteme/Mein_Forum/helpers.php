<?php
require_once "config.php";

define('MAXBODY', 600);
define('MAXNAME', 100);
define('MINPASSWD', 5);
define('LOCKED', ' [gesperrt]');

$mysqli = new mysqli(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);

if (mysqli_connect_errno()) {
    printf("FEHLER: Datenbank nicht erreichbar: <p><b>%s</b></p>", mysqli_connect_error());
    exit();
}

function err_msg($msg, $err) {
    printf("Server-Fehler: %s<p><b>%s</b></p>", $msg, $err);
}

function console_log($msg) {
    echo "<script>";
    echo "console.log(". json_encode($msg) .")";
    echo "</script>";
}

function check_user($id) {
    global $mysqli;

    $logged_user = "";
    $user_is_admin = false;
    $user_locked = true;
    $guest = true;

    if (!is_numeric($id)) {
        $logged_user = 'Gast';
    } else {
        $sql = "SELECT username, is_admin, locked FROM user WHERE id=$id";
        $result = $mysqli->query($sql);
        if ($result->num_rows > 0) {
            $row = mysqli_fetch_row($result);
            $logged_user = $row[0];
            $user_is_admin = $row[1];
            $user_locked = $row[2];
            $guest = false;
        } else {
            header("location: " .HOMEDIR. "logout.php");
            exit;
        }
    }

    return ['logged_user'=>$logged_user, 'user_is_admin'=>$user_is_admin,
            'user_locked'=>$user_locked, 'guest'=>$guest];
}

/* builder for simple queries with 1-0 outcome */
function exec_sql($sql, $param, $types="") {
    global $mysqli;
    if ($stmt = $mysqli->prepare($sql)) {
        $stmt->bind_param($types, ...$param);
        if (!$stmt->execute()) {
            err_msg(" exec_sql (executing): " . $sql , $mysqli->error);
            $stmt->close();
            return false;
        }
        $stmt->close();
    } else {
        err_msg(" exec_sql (preparing): " . $sql, $mysqli->error);
        return false;
    }
    return true;
}

function boilerplate_head($title) {
    $head = '';
    $head .= '<link rel="icon" type="image/png" href="' .INDEXFILES. 'favicon.png" />';
    $head .= '<meta charset="utf-8">';
    $head .= '<meta name="viewport" content="width=device-width, initial-scale=1">';
    $head .= '<meta name="description" content="Mein Forum [Test-Forum zum Assignment DBA20]">';
    $head .= '<meta name="author" content="vladimir@vlzware.com">';

    $head .= '<title>Mein Forum | ' .$title. '</title>';

    $head .= '<link rel="stylesheet" href="' .BOOTSTRAP. '"/>';
    $head .= '<link rel="stylesheet" href="' .INDEXFILES. 'styles.css">';

    return $head;
}
?>
