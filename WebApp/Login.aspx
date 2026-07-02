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
    <body>
    <form id="form1" runat="server">
        <div class="auth-split">

            <%-- Panel izquierdo: hero --%>
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

            <%-- Panel derecho: formulario --%>
            <div class="auth-panel">
                <div class="auth-box">

                    <h2>Iniciar sesión</h2>
                    <p class="auth-subtitle">Ingresá con tu cuenta del complejo.</p>

                    <asp:Literal ID="litExito" runat="server" Visible="false" />
                    <asp:Literal ID="litError" runat="server" Visible="false" />

                    <div class="mb-3">
                        <label class="auth-label">Email</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="auth-input"
                            TextMode="Email" placeholder="usuario@complejo.com" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEmail"
                            ValidationGroup="Login" CssClass="text-danger small"
                            ErrorMessage="El email es obligatorio." Display="Dynamic" />
                    </div>

                    <div class="mb-3">
                        <label class="auth-label">Contraseña</label>
                        <asp:TextBox ID="txtPassword" runat="server" CssClass="auth-input"
                            TextMode="Password" placeholder="••••••••" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtPassword"
                            ValidationGroup="Login" CssClass="text-danger small"
                            ErrorMessage="La contraseña es obligatoria." Display="Dynamic" />
                    </div>

                    <asp:Button ID="btnLogin" runat="server" Text="Iniciar sesión"
                        CssClass="auth-btn" OnClick="btnLogin_Click" ValidationGroup="Login" />

                    <div class="text-end mt-2">
                        <a href="RecuperarContrasenia.aspx" class="auth-link">¿Olvidaste tu contraseña?</a>
                    </div>

                    <div class="auth-divider">¿Sos cliente?</div>

                    <a href="Registrarse.aspx" class="auth-register-cta">
                        <div>
                            <strong>Crear cuenta</strong>
                            <span>Registrate y reservá tu cancha</span>
                        </div>
                        <span class="auth-register-cta-arrow">›</span>
                    </a>

                </div>
            </div>

        </div>
    </form>
</body>
</html>