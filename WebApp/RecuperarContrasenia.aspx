<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RecuperarContrasenia.aspx.cs" Inherits="WebApp.RecuperarContrasenia" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Recuperar contraseña — Complejo Deportivo</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB" crossorigin="anonymous" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js" integrity="sha384-FKyoEForCGlyvwx9Hj09JcYn3nv7wiPVlz7YYwJrWVcXK/BmnVDxM+D2scQbITxI" crossorigin="anonymous"></script>
    <link href="Site.css" rel="stylesheet" />
</head>
<body class="bg-light d-flex align-items-center justify-content-center min-vh-100">
    <form id="form1" runat="server">
        <div class="card app-card p-4" style="width: 420px;">

            <div class="text-center mb-4">
                <h4 class="fw-semibold mb-1">Recuperar contraseña</h4>
                <p class="text-muted small mb-0">Complejo Deportivo</p>
            </div>

            <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger d-block mb-3" Visible="false" />
            <asp:Label ID="lblOk" runat="server" CssClass="alert alert-success d-block mb-3" Visible="false" />

            <asp:Panel ID="pnlVerificar" runat="server">
                <p class="text-muted small">Confirmá tus datos para verificar tu identidad.</p>

                <div class="mb-3">
                    <label class="form-label fw-semibold">DNI</label>
                    <asp:TextBox ID="txtDNI" runat="server" CssClass="form-control" placeholder="Ej: 99999999" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtDNI"
                        ValidationGroup="Verificar" CssClass="text-danger small"
                        ErrorMessage="El DNI es obligatorio." Display="Dynamic" />
                </div>

                <div class="mb-3">
                    <label class="form-label fw-semibold">Email</label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="usuario@complejo.com" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEmail"
                        ValidationGroup="Verificar" CssClass="text-danger small"
                        ErrorMessage="El email es obligatorio." Display="Dynamic" />
                </div>

                <div class="mb-4">
                    <label class="form-label fw-semibold">Fecha de nacimiento</label>
                    <asp:TextBox ID="txtFechaNacimiento" runat="server" CssClass="form-control" TextMode="Date" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtFechaNacimiento"
                        ValidationGroup="Verificar" CssClass="text-danger small"
                        ErrorMessage="La fecha de nacimiento es obligatoria." Display="Dynamic" />
                </div>

                <asp:Button ID="btnVerificar" runat="server" Text="Verificar identidad"
                    CssClass="btn btn-success w-100" OnClick="btnVerificar_Click"
                    ValidationGroup="Verificar" />
            </asp:Panel>

            <asp:Panel ID="pnlNuevaPassword" runat="server" Visible="false">
                <p class="text-muted small">Identidad verificada. Ingresá tu nueva contraseña.</p>

                <asp:HiddenField ID="hfIdUsuario" runat="server" />

                <div class="mb-3">
                    <label class="form-label fw-semibold">Nueva contraseña</label>
                    <asp:TextBox ID="txtNuevaPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="••••••••" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtNuevaPassword"
                        ValidationGroup="Reset" CssClass="text-danger small"
                        ErrorMessage="La contraseña es obligatoria." Display="Dynamic" />
                    <asp:RegularExpressionValidator runat="server" ControlToValidate="txtNuevaPassword"
                        ValidationGroup="Reset" CssClass="text-danger small" Display="Dynamic"
                        ValidationExpression=".{6,}"
                        ErrorMessage="Debe tener al menos 6 caracteres." />
                </div>

                <div class="mb-4">
                    <label class="form-label fw-semibold">Confirmar contraseña</label>
                    <asp:TextBox ID="txtConfirmarPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="••••••••" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtConfirmarPassword"
                        ValidationGroup="Reset" CssClass="text-danger small"
                        ErrorMessage="Confirmá la contraseña." Display="Dynamic" />
                    <asp:CompareValidator runat="server" ControlToValidate="txtConfirmarPassword"
                        ControlToCompare="txtNuevaPassword" ValidationGroup="Reset"
                        CssClass="text-danger small" Display="Dynamic"
                        ErrorMessage="Las contraseñas no coinciden." />
                </div>

                <asp:Button ID="btnGuardarPassword" runat="server" Text="Guardar nueva contraseña"
                    CssClass="btn btn-success w-100" OnClick="btnGuardarPassword_Click"
                    ValidationGroup="Reset" />
            </asp:Panel>

            <div class="text-center mt-3">
                <a href="Login.aspx" class="small">Volver a iniciar sesión</a>
            </div>

        </div>
    </form>
</body>
</html>
