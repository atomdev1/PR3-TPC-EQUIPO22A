<%@ Page Title="Usuarios" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Usuarios.aspx.cs" Inherits="WebApp.Usuarios" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="d-flex align-items-center mb-4">
        <div>
            <h2 class="mb-0">Usuarios</h2>
            <small class="text-muted">Gestión de cuentas y roles del sistema</small>
        </div>
        <asp:Button ID="btnNuevoUsuario" runat="server" CssClass="btn-r btn-primary-r ms-auto"
            Text="+ Nuevo usuario" OnClick="btnNuevoUsuario_Click" CausesValidation="false" />
    </div>

    <%-- Filtros --%>
    <div class="card-r mb-4 p-3">
        <div class="row g-2 align-items-end">
            <div class="col-md-4">
                <label class="form-label small fw-semibold mb-1">Rol</label>
                <asp:DropDownList ID="ddlFiltroRol" runat="server"
                    CssClass="form-select form-select-sm"
                    AutoPostBack="true" OnSelectedIndexChanged="Filtrar">
                    <asp:ListItem Value="0">Todos los roles</asp:ListItem>
                    <asp:ListItem Value="1">Administrador</asp:ListItem>
                    <asp:ListItem Value="2">Recepcionista</asp:ListItem>
                    <asp:ListItem Value="3">Encargado de Cancha</asp:ListItem>
                    <asp:ListItem Value="4">Cliente</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-md-4">
                <label class="form-label small fw-semibold mb-1">Estado</label>
                <asp:DropDownList ID="ddlFiltroEstado" runat="server"
                    CssClass="form-select form-select-sm"
                    AutoPostBack="true" OnSelectedIndexChanged="Filtrar">
                    <asp:ListItem Value="0">Todos los estados</asp:ListItem>
                    <asp:ListItem Value="1">Activo</asp:ListItem>
                    <asp:ListItem Value="2">Inactivo</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-md-4">
                <asp:LinkButton ID="btnLimpiarFiltros" runat="server"
                    CssClass="btn btn-sm btn-outline-secondary w-100"
                    OnClick="LimpiarFiltros">Limpiar filtros</asp:LinkButton>
            </div>
        </div>
    </div>

    <%-- Confirmación de baja --%>
    <asp:Panel ID="pnlConfirmarBaja" runat="server" Visible="false"
        CssClass="alert alert-warning d-flex justify-content-between align-items-center mb-4">
        <asp:Label ID="lblConfirmarBaja" runat="server" CssClass="mb-0" />
        <div class="d-flex gap-2">
            <asp:Button ID="btnConfirmarBaja" runat="server" Text="Sí, dar de baja"
                CssClass="btn btn-sm btn-danger" OnClick="btnConfirmarBaja_Click" CausesValidation="false" />
            <asp:Button ID="btnCancelarBaja" runat="server" Text="Cancelar"
                CssClass="btn-r btn-sm-r btn-ghost-r" OnClick="btnCancelarBaja_Click" CausesValidation="false" />
        </div>
    </asp:Panel>
    <asp:HiddenField ID="hfBajaId" runat="server" />

    <%-- Grid de usuarios --%>
    <div class="table-responsive">
        <asp:Repeater ID="rptUsuarios" runat="server" OnItemCommand="rptUsuarios_ItemCommand">
            <HeaderTemplate>
                <table class="table table-hover align-middle mb-0">
                    <thead>
                        <tr>
                            <th>Nombre</th>
                            <th>DNI</th>
                            <th>Email</th>
                            <th>Teléfono</th>
                            <th>Rol</th>
                            <th>Estado</th>
                            <th class="text-end">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
            </HeaderTemplate>
            <ItemTemplate>
                <tr>
                    <td class="fw-semibold"><%# Eval("Nombre") %> <%# Eval("Apellido") %></td>
                    <td><%# Eval("DNI") %></td>
                    <td><%# Eval("Email") %></td>
                    <td><%# string.IsNullOrEmpty((string)Eval("Telefono")) ? "—" : Eval("Telefono") %></td>
                    <td><span class="badge bg-primary"><%# GetRolNombre(Eval("Rol")) %></span></td>
                    <td><span class='<%# GetEstadoBadgeClass(Eval("Activo")) %>'><%# GetEstadoTexto(Eval("Activo")) %></span></td>
                    <td class="text-end">
                        <asp:LinkButton runat="server" CommandName="VerPerfil"
                            CommandArgument='<%# Eval("IdUsuario") %>'
                            CssClass="btn-r btn-sm-r btn-ghost-r">
                            Ver perfil
                        </asp:LinkButton>
                        <asp:LinkButton runat="server" CommandName="Editar" CommandArgument='<%# Eval("IdUsuario") %>'
                            CssClass="btn-r btn-sm-r btn-ghost-r">Editar</asp:LinkButton>
                        <asp:LinkButton runat="server" CommandName="Baja" CommandArgument='<%# Eval("IdUsuario") %>'
                            CssClass="btn btn-sm btn-outline-danger" Visible='<%# (bool)Eval("Activo") %>'>Dar de baja</asp:LinkButton>
                        <asp:LinkButton runat="server" CommandName="Reactivar" CommandArgument='<%# Eval("IdUsuario") %>'
                            CssClass="btn btn-sm btn-outline-success" Visible='<%# !(bool)Eval("Activo") %>'>Reactivar</asp:LinkButton>
                    </td>
                </tr>
            </ItemTemplate>
            <FooterTemplate>
                    </tbody>
                </table>
            </FooterTemplate>
        </asp:Repeater>
    </div>

    <%-- Modal Nuevo/Editar Usuario --%>
    <div class="modal fade" id="modalUsuario" tabindex="-1" aria-labelledby="modalUsuarioLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="modalUsuarioLabel">Nuevo usuario</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hfIdUsuario" runat="server" />
                    <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger d-block" Visible="false" />
                    <div class="row g-3">

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">DNI</label>
                            <asp:TextBox ID="txtDNI" runat="server" CssClass="form-control" MaxLength="20" />
                            <asp:RequiredFieldValidator ID="rfvDNI" runat="server" ControlToValidate="txtDNI"
                                ValidationGroup="Usuario" CssClass="text-danger small" Display="Dynamic"
                                ErrorMessage="El DNI es obligatorio." />
                            <asp:RegularExpressionValidator ID="revDNI" runat="server" ControlToValidate="txtDNI"
                                ValidationGroup="Usuario" CssClass="text-danger small" Display="Dynamic"
                                ValidationExpression="^\d{7,20}$" ErrorMessage="El DNI debe ser numérico (7 a 20 dígitos)." />
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Rol</label>
                            <asp:DropDownList ID="ddlRol" runat="server" CssClass="form-select">
                                <asp:ListItem Value="0">-- Seleccioná un rol --</asp:ListItem>
                                <asp:ListItem Value="1">Administrador</asp:ListItem>
                                <asp:ListItem Value="2">Recepcionista</asp:ListItem>
                                <asp:ListItem Value="3">Encargado de Cancha</asp:ListItem>
                                <asp:ListItem Value="4">Cliente</asp:ListItem>
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvRol" runat="server" ControlToValidate="ddlRol"
                                InitialValue="0" ValidationGroup="Usuario" CssClass="text-danger small" Display="Dynamic"
                                ErrorMessage="Seleccioná un rol." />
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Nombre</label>
                            <asp:TextBox ID="txtNombre" runat="server" CssClass="form-control" MaxLength="100" />
                            <asp:RequiredFieldValidator ID="rfvNombre" runat="server" ControlToValidate="txtNombre"
                                ValidationGroup="Usuario" CssClass="text-danger small" Display="Dynamic"
                                ErrorMessage="El nombre es obligatorio." />
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Apellido</label>
                            <asp:TextBox ID="txtApellido" runat="server" CssClass="form-control" MaxLength="100" />
                            <asp:RequiredFieldValidator ID="rfvApellido" runat="server" ControlToValidate="txtApellido"
                                ValidationGroup="Usuario" CssClass="text-danger small" Display="Dynamic"
                                ErrorMessage="El apellido es obligatorio." />
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Email</label>
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" MaxLength="100" />
                            <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail"
                                ValidationGroup="Usuario" CssClass="text-danger small" Display="Dynamic"
                                ErrorMessage="El email es obligatorio." />
                            <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail"
                                ValidationGroup="Usuario" CssClass="text-danger small" Display="Dynamic"
                                ValidationExpression="^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$" ErrorMessage="Ingresá un email válido." />
                        </div>

                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Teléfono</label>
                            <asp:TextBox ID="txtTelefono" runat="server" CssClass="form-control" MaxLength="20" />
                        </div>

                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Fecha de nacimiento</label>
                            <asp:TextBox ID="txtFechaNacimiento" runat="server" CssClass="form-control" TextMode="Date" />
                            <asp:RequiredFieldValidator ID="rfvFechaNac" runat="server" ControlToValidate="txtFechaNacimiento"
                                ValidationGroup="Usuario" CssClass="text-danger small" Display="Dynamic"
                                ErrorMessage="La fecha de nacimiento es obligatoria." />
                        </div>

                        <asp:Panel ID="pnlPassword" runat="server" CssClass="col-12">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Contraseña</label>
                                    <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" MaxLength="100" />
                                    <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword"
                                        ValidationGroup="Usuario" CssClass="text-danger small" Display="Dynamic"
                                        ErrorMessage="La contraseña es obligatoria." />
                                    <asp:RegularExpressionValidator ID="revPassword" runat="server" ControlToValidate="txtPassword"
                                        ValidationGroup="Usuario" CssClass="text-danger small" Display="Dynamic"
                                        ValidationExpression=".{6,}" ErrorMessage="Mínimo 6 caracteres." />
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Repetir contraseña</label>
                                    <asp:TextBox ID="txtRepetirPassword" runat="server" CssClass="form-control" TextMode="Password" MaxLength="100" />
                                    <asp:RequiredFieldValidator ID="rfvRepetirPassword" runat="server" ControlToValidate="txtRepetirPassword"
                                        ValidationGroup="Usuario" CssClass="text-danger small" Display="Dynamic"
                                        ErrorMessage="Repetí la contraseña." />
                                    <asp:CompareValidator ID="cvRepetirPassword" runat="server" ControlToValidate="txtRepetirPassword"
                                        ControlToCompare="txtPassword" ValidationGroup="Usuario"
                                        CssClass="text-danger small" Display="Dynamic"
                                        ErrorMessage="Las contraseñas no coinciden." />
                                </div>
                                <div class="col-12">
                                    <small class="text-muted">Mínimo 6 caracteres. Se pide solo al crear el usuario.</small>
                                </div>
                            </div>
                        </asp:Panel>

                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-r btn-ghost-r" data-bs-dismiss="modal">Cancelar</button>
                    <asp:Button ID="btnGuardarUsuario" runat="server" Text="Guardar usuario"
                        CssClass="btn-r btn-primary-r" OnClick="btnGuardarUsuario_Click" ValidationGroup="Usuario" />
                </div>
            </div>
        </div>
    </div>

</asp:Content>
