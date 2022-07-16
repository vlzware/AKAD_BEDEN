<?php
session_start();
require_once "helpers.php";

$check = check_user(isset($_SESSION["id"])? $_SESSION["id"] : false);
$logged_user = $check['logged_user'];

/* only admin allowed to manage accounts */
if (!$check['user_is_admin']) {
    header("location: " .HOME);
    exit;
}

$username = $password = $confirm_password = "";
$username_err = $password_err = $confirm_password_err = "";
$is_admin = 0;
$update_password = 0;

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    $password = $_POST["password"];

    if (isset($_POST["update_password"])) {
        $username = $_POST["sf_name"];
        $hash_password = password_hash($password, PASSWORD_DEFAULT);
        $sql = "UPDATE user SET password=? WHERE username=?";
        if (exec_sql($sql, [$hash_password, $username], "ss")) {
            //echo "Success!"; // this interferes with the redirection
            /* TODO: some kind of confirmation */
        }
        header("location: " .HOMEDIR. "users.php");
        exit;
    }

    $username = $_POST["username"];
    $confirm_password = $_POST["confirm_password"];
    $is_admin = isset($_POST['is_admin']);
    $update_password = isset($_POST["update_password"]);

    if(!preg_match('/^\w{3,}$/', $username)) {
        $username_err = "Bitte Benutzername eingeben (mind. 3 Symbole, erlaubte Zeichen: 0-9A-Za-z_ )";

    } else {
        $sql = "SELECT id FROM user WHERE username = ?";
        if ($stmt = $mysqli->prepare($sql)) {

            $stmt->bind_param("s", $username);

            if (!$stmt->execute()) {
                err_msg("users (checking name)", $mysqli->error);
                $stmt->close();
                exit;
            }

            $stmt->store_result();
            if ($stmt->num_rows > 0) {
                $username_err = "Benutzername existiert.";
            }

            $stmt->close();
        } else {
            err_msg("mysqli prepare", $mysqli->error);
            exit;
        }
    }

    if (empty($password)) {
        $password_err = "Bitte Passwort eingeben.";

    } elseif (strlen($password) < MINPASSWD) {
        $password_err = "Das Passwort muss mindestens " .MINPASSWD. "Zeichen haben.";
    }

    if (empty($confirm_password)) {
        $confirm_password_err = "Bitte das Passwort bestätigen.";

    } else {
        if (empty($password_err) && ($password != $confirm_password)) {
            $confirm_password_err = "Die Passwörter stimmen nicht überein.";
        }
    }

    /* no errors? */
    if (empty($username_err) && empty($password_err) && empty($confirm_password_err)) {

        $sql = "INSERT INTO user (username, password, is_admin) VALUES (?, ?, ?)";
        $hash_password = password_hash($password, PASSWORD_DEFAULT);

        if (exec_sql($sql, [ $username, $hash_password, $is_admin ], "ssi")) {
            header("location: " .HOMEDIR. "users.php");
            exit;
        }
    }
}
?>

<!DOCTYPE html>
<html lang="de">
<head>
    <?php echo boilerplate_head('Benutzer verwalten'); ?>
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
    <div id="users" class="screen_middle screen_middle_w">
        <h2>Registrierte Benutzer:</h2>
        <table>
            <tr>
                <th class="users_name">Benutzer</th>
                <th>Seit</th>
                <th class="users_control"><img src="index_files/admin.png" alt="Administrator" title="Administrator" /></th>
                <th class="users_control"><img src="index_files/lock.png" alt="Gesperrt" title="Gesperrt" /></th>
                <th class="users_pwd">Neues Passwort</th>
            </tr>
            <?php
            $sql = "SELECT id, username AS 'name', is_admin,
                    CONVERT_TZ(user.created,'+00:00','".TIMEOFFSET."') AS 'created',
                    locked FROM user";
            $result = $mysqli->query($sql);
            if ($result->num_rows > 0) {
                while($row = $result->fetch_assoc()) {
                    $id = $row["id"];
                    $name = $row["name"];
                    $created = $row["created"];
                    $is_admin = $row["is_admin"];
                    $locked = $row["locked"];

                    if ($name == "[entfernt]") {
                        continue;
                    }

                    echo "<tr>";
                    echo "  <td class=\"users_name\">";
                    echo ($name === "admin")? "<b>admin</b>" : $name;
                    echo "  </td>";
                    echo "  <td>$created</td>";

                    if ($is_admin) {
                        /* can't un-admin admin */
                        if ($name === "admin") {
                            echo "  <td><img src=\"index_files/check.png\" /></td>";
                        } else {
                            echo "  <td><a class=\"check\" href=\"".HOMEDIR."manageuser.php/?id=$id&noadmin\" title=\"Administartor-Rechte beheben\"></a></td>";
                        }
                    } else {
                        echo "  <td><a class=\"uncheck\" href=\"".HOMEDIR."manageuser.php/?id=$id&admin\" title=\"Administartor-Rechte geben\"></a></td>";
                    }

                    if ($locked) {
                        echo "  <td><a class=\"check\" href=\"".HOMEDIR."manageuser.php/?id=$id&unlock\" title=\"Benutzer entsperren\"></a></td>";
                    } else {
                        /* can't lock admin */
                        if ($name === "admin") {
                            echo "  <td><div class=\"dummy\"></div></td>";
                        } else {
                            echo "  <td><a class=\"uncheck\" href=\"".HOMEDIR."manageuser.php/?id=$id&lock\" title=\"Benutzer sperren\"></a></td>";
                        }
                    }

                    echo "
                        <td>
                            <form action=\"".HOMEDIR."users.php\" method =\"post\">
                                <input style=\"width: 100px; position: absolute; margin-left: 0;\" type=\"password\" name=\"password\" />
                                <input type=\"hidden\" name=\"sf_name\" value=\"".$name."\" />
                                <input type=\"hidden\" name=\"update_password\" />
                                <input style=\"width: 50px; margin-left: 105px;\" type=\"submit\" class=\"btn btn-primary btn-sm\" value=\"Los !\" />
                            </form>
                        </td>";

                    if ($name === "admin") {
                        echo "  <td><div class=\"dummy\"></div></td>";
                    } else {
                        echo "  <td><a class=\"trash\" href=\"".HOMEDIR."manageuser.php/?id=$id&del\" title=\"Benutzer löschen ( ! )\"></a></td>";
                    }

                    echo "</tr>";
                }
            }
            ?>
        </table>
    </div>
    <hr />
    <div id="register" class="screen_middle">
        <h2>Neues Benutzerkonto anlegen</h2>
        <form action="<?php echo HOMEDIR."users.php"; ?>" method="post">

            <div class="form-group <?php echo (!empty($username_err)) ? 'has-error' : ''; ?>">
                <label>Benutzername</label>
                <input type="text" name="username" class="form-control" value="<?php echo $username; ?>" />
                <span class="help-block"><?php echo $username_err; ?></span>
            </div>

            <div class="form-group <?php echo (!empty($password_err)) ? 'has-error' : ''; ?>">
                <label>Passwort</label>
                <input type="password" name="password" class="form-control" value="<?php echo $password; ?>" />
                <span class="help-block"><?php echo $password_err; ?></span>
            </div>

            <div class="form-group <?php echo (!empty($confirm_password_err)) ? 'has-error' : ''; ?>">
                <label>Passwort erneut</label>
                <input type="password" name="confirm_password" class="form-control" value="<?php echo $confirm_password; ?>" />
                <span class="help-block"><?php echo $confirm_password_err; ?></span>
            </div>

            <div class="form-group">
                <input type="checkbox" name="is_admin" value="is_admin" /> Administartor Rechte
            </div>

            <div class="form-group">
                <input type="submit" class="btn btn-primary" value="Los !" />
                <input type="reset" class="btn btn-default" value="Reset" />
            </div>

        </form>
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
