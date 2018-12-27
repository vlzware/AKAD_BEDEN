<?php
session_start();
require_once "helpers.php";

/* properly called? */
if ( !isset($_GET["id"]) || !ctype_digit($_GET["id"]) ) {
    header("location: " .HOME);
    exit;
}

$check = check_user(isset($_SESSION["id"])? $_SESSION["id"] : false);
$logged_user = $check['logged_user'];
$user_is_admin = $check['user_is_admin'];
$user_locked = $check['user_locked'];
$guest = $check['guest'];

$thread_id = $_GET["id"];
$thread_name = "";
$thread_locked = false;
$msg_count = 0;

$sql = "SELECT name, locked, msg_count FROM thread WHERE id=$thread_id";
$result = $mysqli->query($sql);
if ($result->num_rows > 0) {
    $row = mysqli_fetch_row($result);
    $thread_name = $row[0];
    $thread_locked = $row[1];
    $msg_count = $row[2];
} else {
    header("location: " .HOME);
    exit;
}
?>

<!DOCTYPE html>
<html lang="de">

<head>
    <?php echo boilerplate_head($thread_name); ?>
</head>
<body>
    <div id="header">
        <h1><a class="nostyle" href="<?php echo HOME; ?>">Mein Forum</a></h1>
        <p>Test-Forum zum Assignment "Forum" für DBA20 [AKAD]</p>
    </div>

    <div id="topnav">
        <a id="btn_back" href="<?php echo HOME; ?>" class="btn btn-default btn-sm">[ Zurück ]</a>
        <div class="curr_user">
            <?php
            echo "Eingeloggt als <b>".$logged_user."</b>. ";
            ?>
        </div>
    </div>

    <h3><?php echo $thread_name ?></h3>
    <table class="odd_rows">
        <?php
        $sql = "SELECT msg.id, CONVERT_TZ(msg.datetime,'+00:00','".TIMEOFFSET."') AS 'datetime',
                msg.body, user.username, user.locked AS 'user_locked' FROM msg
                INNER JOIN user ON user.id=msg.user_id WHERE msg.thread_id=$thread_id
                ORDER BY datetime";
        $result = $mysqli->query($sql);
        if ($result->num_rows > 0) {
            while($row = $result->fetch_assoc()) {
                $msg_id = $row["id"];
                echo "<tr>";
                echo "<td class=\"table_view_user\"><p><b>" . ($row["user_locked"]? LOCKED:$row["username"]) . "</b></p>" . $row["datetime"] . "</td>";
                echo "<td class=\"table_view_body\">" . $row["body"] . "</td>";

                /* edits allowed on the own message or admin */
                if ((!$guest && $logged_user === $row["username"]) || ($user_is_admin)) {
                    echo
                    "<td class=\"table_adv_controls\">"
                        ."<a class=\"edit\" href=\"".HOMEDIR."editmsg.php/?msg_id=$msg_id\" title=\"Nachricht bearbeiten\"></a>"
                    ."</td>";
                } else {
                    echo
                    "<td class=\"table_adv_controls\">"
                        ."<div class=\"dummy\" ></div>"
                    ."</td>";
                }
                if ($user_is_admin && ($msg_count > 1)) {
                    $msg_id = $row["id"];
                    echo
                    "<td class=\"table_adv_controls\">"
                        ."<a class=\"trash\" href=\"".HOMEDIR."managemsg.php/?thread_id=$thread_id&msg_id=$msg_id&del\" title=\"Nachricht löschen\"></a>"
                    ."</td>";
                }
                echo "</tr>";
            }
        } else {
            header("location: " .HOME);
            exit;
        }
        ?>
    </table>
    <div id="btn_new_msg">
        <?php
        if (!$guest && !$user_locked) {
            if ($thread_locked) {
                echo "<a href=\"#\" title=\"Dieses Thema ist gesperrt.\" class=\"btn btn-default btn-sm disabled\">Neue Antwort</a>";
            } else {
                echo "<a href=\"".HOMEDIR."newmsg.php/?thread_id=$thread_id\" class=\"btn btn-default btn-sm\">Neue Antwort</a>";
            }
        }
        ?>
    </div>

    <hr class="footer_space" />
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
