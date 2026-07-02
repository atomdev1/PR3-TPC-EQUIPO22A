<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Registrarse.aspx.cs" Inherits="WebApp.Registrarse" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Crear cuenta — Complejo Deportivo</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB" crossorigin="anonymous" />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@400;700;800&family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <link href="Site.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="auth-split">

            <%-- Panel izquierdo: idéntico al Login --%>
            <div class="auth-hero">
                <div class="auth-hero-brand">
                    <div class="auth-brand-mark">CD</div>
                    <div>
                        <div class="auth-brand-name">Complejo Deportivo</div>
                        <div class="auth-brand-sub">Sistema de gestión</div>
                    </div>
                </div>

                <div class="auth-hero-body">
                    <p class="auth-eyebrow">Complejo Deportivo</p>
                    <h1 class="auth-headline">Tu cancha,<br />tu juego,<br />en un clic.</h1>
                    <p class="auth-desc">Reservá, gestioná y jugá. Una plataforma para clientes, recepción, encargados y administración.</p>
                </div>

                <div class="auth-stats">
                    <div>
                        <div class="auth-stat-val">+200</div>
                        <div class="auth-stat-lbl">reservas / mes</div>
                    </div>
                    <div>
                        <div class="auth-stat-val">4</div>
                        <div class="auth-stat-lbl">roles de acceso</div>
                    </div>
                </div>
            </div>

            <%-- Panel derecho: formulario de registro --%>
            <div class="auth-panel">
                <div class="auth-box">

                    <h2>Crear cuenta</h2>
                    <p class="auth-subtitle">Completá tus datos para registrarte como cliente.</p>

                    <asp:Literal ID="litError" runat="server" Visible="false" />

                    <div class="row g-3 mb-3">
                        <div class="col-6">
                            <label class="auth-label">Nombre</label>
                            <asp:TextBox ID="txtNombre" runat="server" CssClass="auth-input" placeholder="Juan" />
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtNombre"
                                ValidationGroup="Registro" CssClass="text-danger small"
                                ErrorMessage="Obligatorio." Display="Dynamic" />
                        </div>
                        <div class="col-6">
                            <label class="auth-label">Apellido</label>
                            <asp:TextBox ID="txtApellido" runat="server" CssClass="auth-input" placeholder="Pérez" />
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtApellido"
                                ValidationGroup="Registro" CssClass="text-danger small"
                                ErrorMessage="Obligatorio." Display="Dynamic" />
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="auth-label">DNI</label>
                        <asp:TextBox ID="txtDNI" runat="server" CssClass="auth-input" placeholder="Ej: 99999999" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtDNI"
                            ValidationGroup="Registro" CssClass="text-danger small"
                            ErrorMessage="El DNI es obligatorio." Display="Dynamic" />
                    </div>

                    <div class="mb-3">
                        <label class="auth-label">Email</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="auth-input"
                            TextMode="Email" placeholder="juan@correo.com" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEmail"
                            ValidationGroup="Registro" CssClass="text-danger small"
                            ErrorMessage="El email es obligatorio." Display="Dynamic" />
                    </div>

                    <div class="mb-3">
                        <label class="auth-label">Teléfono <span class="fw-normal text-faint">(opcional)</span></label>
                        <asp:TextBox ID="txtTelefono" runat="server" CssClass="auth-input" placeholder="Ej: 1122334455" />
                    </div>

                    <div class="mb-3">
                        <label class="auth-label">Fecha de nacimiento</label>
                        <asp:TextBox ID="txtFechaNacimiento" runat="server" CssClass="auth-input" TextMode="Date" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtFechaNacimiento"
                            ValidationGroup="Registro" CssClass="text-danger small"
                            ErrorMessage="La fecha de nacimiento es obligatoria." Display="Dynamic" />
                    </div>

                    <div class="mb-3">
                        <label class="auth-label">Contraseña</label>
                        <asp:TextBox ID="txtPassword" runat="server" CssClass="auth-input"
                            TextMode="Password" placeholder="••••••••" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtPassword"
                            ValidationGroup="Registro" CssClass="text-danger small"
                            ErrorMessage="La contraseña es obligatoria." Display="Dynamic" />
                        <asp:RegularExpressionValidator runat="server" ControlToValidate="txtPassword"
                            ValidationGroup="Registro" CssClass="text-danger small" Display="Dynamic"
                            ValidationExpression=".{6,}" ErrorMessage="Mínimo 6 caracteres." />
                    </div>

                    <div class="mb-4">
                        <label class="auth-label">Confirmar contraseña</label>
                        <asp:TextBox ID="txtConfirmarPassword" runat="server" CssClass="auth-input"
                            TextMode="Password" placeholder="••••••••" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtConfirmarPassword"
                            ValidationGroup="Registro" CssClass="text-danger small"
                            ErrorMessage="Confirmá la contraseña." Display="Dynamic" />
                        <asp:CompareValidator runat="server" ControlToValidate="txtConfirmarPassword"
                            ControlToCompare="txtPassword" ValidationGroup="Registro"
                            CssClass="text-danger small" Display="Dynamic"
                            ErrorMessage="Las contraseñas no coinciden." />
                    </div>

                    <asp:Button ID="btnRegistrarse" runat="server" Text="Crear cuenta"
                        CssClass="auth-btn" OnClick="btnRegistrarse_Click" ValidationGroup="Registro" />

                    <div class="text-center mt-3">
                        <a href="Login.aspx" class="auth-link">¿Ya tenés cuenta? Iniciá sesión</a>
                    </div>

                </div>
            </div>

        </div>
    </form>
</body>
</html>
