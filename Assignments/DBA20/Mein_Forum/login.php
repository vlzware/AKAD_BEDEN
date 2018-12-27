<?php
session_start();
require_once "helpers.php";

/* already loggen in? */
$check = check_user(isset($_SESSION["id"])? $_SESSION["id"] : false);
if (!$check['guest']) {
    header("location: " .HOME);
    exit;
}

$username = $password = "";
$username_err = $password_err = "";

if($_SERVER["REQUEST_METHOD"] == "POST"){

    $username = $_POST["username"];
    $password = $_POST["password"];
    $cred_err = false;

    if (empty($username)){
        $username_err = "Bitte Benutzername eingeben!";
        $cred_err = true;
    }

    if (empty($password)) {
        $password_err = "Bitte Password eingeben!";
        $cred_err = true;
    }

    /* credentials ok? */
    if (!$cred_err) {
        $sql = "SELECT id, password FROM user WHERE username = ?";

        if ($stmt = $mysqli->prepare($sql)) {
            $stmt->bind_param("s", $username);

            if (!$stmt->execute()) {
                err_msg("login", $mysqli->error);
                $stmt->close();
                exit;
            }

            $stmt->store_result();
            if ($stmt->num_rows == 1) {

                $stmt->bind_result($id, $hashed_password);
                if ($stmt->fetch()) {

                    if (password_verify($password, $hashed_password)) {

                        /* all ok */
                        session_start();    /* new session */
                        $_SESSION["id"] = $id;
                        $stmt->close();
                        header("location: " .HOME);
                        exit;
                    } else {
                        $password_err = "Ungültiges Passwort.";
                    }
                }

            } else {
                $username_err = "Benutzerkonto existiert nicht.";
            }

            $stmt->close();

        } else {
            err_msg("login", $mysqli->error);
            exit;
        }
    }
}
?>

<!DOCTYPE html>
<html lang="de">
<head>
    <?php echo boilerplate_head("Einloggen"); ?>
</head>
<body>
    <div id="header">
        <h1><a class="nostyle" href="<?php echo HOME; ?>">Mein Forum</a></h1>
        <p>Test-Forum zum Assignment "Forum" für DBA20 [AKAD]</p>
    </div>

    <div id="topnav">
        <a id="btn_back" href="<?php echo HOME; ?>" class="btn btn-default btn-sm">[ Zurück ]</a>
        <div class="curr_user">
            Loggen Sie sich bitte ein.
        </div>
    </div>

    <div id="login" class="screen_middle">
        <h1>Einloggen</h1>
        <form action="<?php echo HOMEDIR."login.php"; ?>" method="post">
            <div class="form-group <?php if (!empty($username_err)) {echo "has-error";} ?>">
                <label>Benutzername</label>
                <input type="text" name="username" class="form-control" value="<?php echo $username; ?>" />
                <span class="help-block"><?php echo $username_err; ?></span>
            </div>

            <div class="form-group <?php if (!empty($password_err)) {echo "has-error";} ?>">
                <label>Password</label>
                <input type="password" name="password" class="form-control" />
                <span class="help-block"><?php echo $password_err; ?></span>
            </div>

            <div class="form-group">
                <input type="submit" class="btn btn-primary" value="Login" />
                <input type="reset" class="btn btn-default" value="Reset" />
            </div>

            <p><a href="mailto:dummy@dummy.dummy" title="">Benutzerkontro beantragen</a>.</p>
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
