<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="WebApp.Login" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Iniciar sesión — Complejo Deportivo</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB" crossorigin="anonymous" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js" integrity="sha384-FKyoEForCGlyvwx9Hj09JcYn3nv7wiPVlz7YYwJrWVcXK/BmnVDxM+D2scQbITxI" crossorigin="anonymous"></script>
    <link href="Site.css" rel="stylesheet" />
</head>
<body class="bg-light d-flex align-items-center justify-content-center min-vh-100">
    <form id="form1" runat="server">
        <div class="card app-card p-4" style="width: 380px;">

            <div class="text-center mb-4">
                <h4 class="fw-semibold mb-1">Complejo Deportivo</h4>
                <p class="text-muted small mb-0">Ingresá con tu cuenta</p>
            </div>

            <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger d-block mb-3"
                Visible="false" />

            <div class="mb-3">
                <label class="form-label fw-semibold">Email</label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control"
                    TextMode="Email" placeholder="usuario@complejo.com" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEmail"
                    ValidationGroup="Login" CssClass="text-danger small"
                    ErrorMessage="El email es obligatorio." Display="Dynamic" />
            </div>

            <div class="mb-4">
                <label class="form-label fw-semibold">Contraseña</label>
                <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control"
                    TextMode="Password" placeholder="••••••••" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtPassword"
                    ValidationGroup="Login" CssClass="text-danger small"
                    ErrorMessage="La contraseña es obligatoria." Display="Dynamic" />
            </div>

            <asp:Button ID="btnLogin" runat="server" Text="Iniciar sesión"
                CssClass="btn btn-success w-100" OnClick="btnLogin_Click"
                ValidationGroup="Login" />

        </div>
    </form>
</body>
</html>