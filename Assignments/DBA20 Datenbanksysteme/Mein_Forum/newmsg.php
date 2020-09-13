<?php
session_start();
require_once "helpers.php";

$check = check_user(isset($_SESSION["id"])? $_SESSION["id"] : false);
$logged_user = $check['logged_user'];

/* user not logged-in/locked ? */
if ($check['user_locked']) {
    header("location: " .HOME);
    exit;
}

/* properly called? */
$thread_id = -1;
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $thread_id = $_POST["thread_id"];
} else {
    if (!isset($_GET["thread_id"]) || !ctype_digit($_GET["thread_id"])) {
        header("location: " .HOME);
        exit;
    }
    $thread_id = $_GET["thread_id"];
}

$thread_name = "";
$thread_locked = 1;

$sql = "SELECT name, locked FROM thread WHERE id=$thread_id";
$result = $mysqli->query($sql);
if ($result->num_rows > 0) {
    $row = mysqli_fetch_row($result);
    $thread_name = $row[0];
    $thread_locked = $row[1];
} else {
    header("location: " .HOME);
    exit;
}

if ($thread_locked) {
    header("location: " .HOMEDIR. "viewthread.php/?id=$thread_id");
    exit;
}

$msg_body = $msg_body_err = "";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $msg_body = $_POST["msg_body"];

    /* body checks */
    if (empty($msg_body)) {
        $msg_body_err = "Ihre Nachricht darf nicht lehr sein.";
    } elseif (strlen($msg_body) > MAXBODY) {
        $msg_body_err = "Versuchen Sie es etwas knapper.";
    }

    /* no errors on input? */
    if (empty($msg_body_err)) {
        $sql = "INSERT INTO msg (body, user_id, thread_id) VALUES (?, ?, ?)";
        if (exec_sql($sql, [ $msg_body, $_SESSION["id"], $thread_id ], "sii")) {
            $sql = "UPDATE thread SET msg_count=msg_count+1 WHERE id=?";
            if (exec_sql($sql, [$thread_id], "i")) {
                header("location: " .HOMEDIR. "viewthread.php/?id=$thread_id");
                exit;
            }
        }
    }
}
?>

<!DOCTYPE html>
<html lang="de">
<head>
    <?php echo boilerplate_head('Neue Antwort zu "' . $thread_name . '"'); ?>
</head>
<body>
    <div id="header">
        <h1><a class="nostyle" href="<?php echo HOME; ?>">Mein Forum</a></h1>
        <p>Test-Forum zum Assignment "Forum" für DBA20 [AKAD]</p>
    </div>

    <div id="topnav">
        <a id="btn_back" href="<?php echo HOMEDIR."viewthread.php/?id=$thread_id" ?>" class="btn btn-default btn-sm">[ Zurück ]</a>
        <div class="curr_user">
            Eingeloggt als <b><?php echo $logged_user; ?></b>.
        </div>
    </div>
    <div id="new_thread" class="screen_middle">
        <h2>Neue Antwort:</h2>
        <form action="<?php echo HOMEDIR. "newmsg.php"; ?>" method="post">
            <div class="form-group">
                <label>Themenname</label>
                <input type="text" name="thread_name" class="form-control" value="<?php echo $thread_name; ?>" disabled />
            </div>

            <div class="form-group <?php if (!empty($msg_body_err)) {echo "has-error";} ?>">
                <label>Ihr Text</label>
                <textarea rows="15" cols="80" name="msg_body" class="form-control"><?php echo $msg_body; ?></textarea>
                <span class="help-block"><?php echo $msg_body_err; ?></span>
            </div>

            <div class="form-group">
                <input type="submit" class="btn btn-primary" value="Los !" />
            </div>

            <input type="hidden" name="thread_id" value="<?php echo $thread_id; ?>" />
        </form>
    </div>

    <hr class="footer_space"/>
    <div id="footer">
        Diese Webseite benutzt Cookies.<br />
        <?php
        echo "php: ";
        echo phpversion();
        echo " | ";
        $result = $mysqli->query("SELECT @@version");
        if ($result->num_rows > 0) {
            $row = $result->fetch_assoc();
            echo "sql: ";
            echo $row["@@version"];
        }
        ?>
        | <a href="http://getbootstrap.com">Bootstrap</a> v3.3.7
    </div>

</body>
</html>
