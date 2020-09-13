<?php
session_start();
require_once "helpers.php";

$check = check_user(isset($_SESSION["id"])? $_SESSION["id"] : false);
$logged_user = $check['logged_user'];

/* user not loggen in/locked ? */
if ($check['user_locked']) {
    header("location: " .HOME);
    exit;
}

$thread_name = $thread_name_err = "";
$thread_body = $thread_body_err = "";

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    $thread_name = $_POST["thread_name"];
    $thread_body = $_POST["thread_body"];

    /* name checks */
    if (empty($thread_name)) {
        $thread_name_err = "Der Themenname darf nicht leer sein.";
    } elseif  (strlen($thread_name) > MAXNAME) {
        $thread_name_err = "Der Themenname darf nicht länger als 100 Zeichen sein.";
    } else {
        $sql = "SELECT id FROM thread WHERE name = ?";
        if ($stmt = $mysqli->prepare($sql)) {

            $stmt->bind_param("s", $thread_name);

            if (!$stmt->execute()) {
                err_msg("newthread", $mysqli->error);
                $stmt->close();
                exit;
            }

            $stmt->store_result();
            if ($stmt->num_rows > 0) {
                $thread_name_err = "Das Thema existiert.";
            }

            $stmt->close();
        } else {
            err_msg("newthread", $mysqli->error);
            exit;
        }
    }

    /* body checks */
    if (empty($thread_body)) {
        $thread_body_err = "Ihr Thema darf nicht lehr sein.";
    } elseif (strlen($thread_body) > MAXBODY) {
        $thread_body_err = "Versuchen Sie es etwas knapper.";
    }

    /* no errors on input? */
    if (empty($thread_name_err) && empty($thread_body_err)) {
        $last_id = 0;

        $sql = "INSERT INTO thread (name, user_id) VALUES (?, ?)";
        if (exec_sql($sql, [ $thread_name, $_SESSION["id"] ], "si")) {
            $last_id = $mysqli->insert_id;

            $sql = "INSERT INTO msg (body, user_id, thread_id) VALUES (?, ?, ?)";
            if (exec_sql($sql, [ $thread_body, $_SESSION["id"], $last_id ], "sii")) {
                /* all ok */
                header("location: " .HOME);
                exit;
            }
        }
    }
}
?>

<!DOCTYPE html>
<html lang="de">
<head>
    <?php echo boilerplate_head('Neues Thema'); ?>
</head>
<body>
    <div id="header">
        <h1><a class="nostyle" href="<?php echo HOME; ?>">Mein Forum</a></h1>
        <p>Test-Forum zum Assignment "Forum" für DBA20 [AKAD]</p>
    </div>

    <div id="topnav">
        <a id="btn_back" href="<?php echo HOME; ?>" class="btn btn-default btn-sm">[ Zurück ]</a>
        <div class="curr_user">
            Eingeloggt als <b><?php echo $logged_user; ?></b>.
        </div>
    </div>
    <div id="new_thread" class="screen_middle">
        <h2>Neues Thema erstellen:</h2>

        <form action="<?php echo HOMEDIR."newthread.php" ?>" method="post">

            <div class="form-group <?php if (!empty($thread_name_err)) {echo "has-error";} ?>">
                <label>Themenname</label>
                <input type="text" name="thread_name" class="form-control" value="<?php echo $thread_name; ?>" />
                <span class="help-block"><?php echo $thread_name_err; ?></span>
            </div>

            <div class="form-group <?php if (!empty($thread_body_err)) {echo "has-error";} ?>">
                <label>Ihr Text</label>
                <textarea rows="15" cols="80" name="thread_body" class="form-control"><?php echo $thread_body; ?></textarea>
                <span class="help-block"><?php echo $thread_body_err; ?></span>
            </div>

            <div class="form-group">
                <input type="submit" class="btn btn-primary" value="Los !" />
            </div>
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
