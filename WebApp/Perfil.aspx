<%@ Page Title="Mi perfil" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Perfil.aspx.cs" Inherits="WebApp.Perfil" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="d-flex align-items-center mb-4">
        <div>
            <h2 class="mb-0">Mi perfil</h2>
            <small class="text-muted">Administrá tu información personal</small>
        </div>
    </div>

    <asp:Label ID="lblExito" runat="server" CssClass="alert alert-success d-block mb-4" Visible="false" />

    <div class="row g-4">

        <%-- Datos personales --%>
        <div class="col-md-6">
            <div class="card-r p-4">
                <h5 class="fw-semibold mb-3">Datos personales</h5>
                <div class="row g-3">
                    <div class="col-6">
                        <label class="form-label small fw-semibold">Nombre</label>
                        <asp:Label ID="lblNombre" runat="server" CssClass="form-control-plaintext" />
                    </div>
                    <div class="col-6">
                        <label class="form-label small fw-semibold">Apellido</label>
                        <asp:Label ID="lblApellido" runat="server" CssClass="form-control-plaintext" />
                    </div>
                    <div class="col-6">
                        <label class="form-label small fw-semibold">DNI</label>
                        <asp:Label ID="lblDNI" runat="server" CssClass="form-control-plaintext" />
                    </div>
                    <div class="col-6">
                        <label class="form-label small fw-semibold">Teléfono</label>
                        <asp:Label ID="lblTelefono" runat="server" CssClass="form-control-plaintext" />
                    </div>
                    <div class="col-12">
                        <label class="form-label small fw-semibold">Email</label>
                        <asp:Label ID="lblEmail" runat="server" CssClass="form-control-plaintext" />
                    </div>
                    <div class="col-6">
                        <label class="form-label small fw-semibold">Fecha de nacimiento</label>
                        <asp:Label ID="lblFechaNacimiento" runat="server" CssClass="form-control-plaintext" />
                    </div>
                    <div class="col-6">
                        <label class="form-label small fw-semibold">Miembro desde</label>
                        <asp:Label ID="lblFechaRegistro" runat="server" CssClass="form-control-plaintext" />
                    </div>
                    <div class="col-6">
                        <label class="form-label small fw-semibold">Rol</label>
                        <asp:Label ID="lblRol" runat="server" CssClass="form-control-plaintext" />
                    </div>
                    <asp:Panel ID="pnlAsistencias" runat="server">
                        <div class="col-6">
                            <label class="form-label small fw-semibold">Asistencias</label>
                            <asp:Label ID="lblAsistencias" runat="server" CssClass="form-control-plaintext fw-semibold" />
                        </div>
                    </asp:Panel>
                </div>
            </div>
        </div>

        <div class="col-md-6">

            <%-- Editar datos --%>
            <div class="card-r p-4 mb-4">
                <h5 class="fw-semibold mb-3">Editar datos</h5>
                <asp:Label ID="lblErrorEditar" runat="server" CssClass="alert alert-danger d-block" Visible="false" />
                <div class="row g-3">
                    <div class="col-6">
                        <label class="form-label fw-semibold">Nombre</label>
                        <asp:TextBox ID="txtNombre" runat="server" CssClass="form-control" MaxLength="100" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtNombre"
                            ValidationGroup="Editar" CssClass="text-danger small"
                            ErrorMessage="El nombre es obligatorio." Display="Dynamic" />
                    </div>
                    <div class="col-6">
                        <label class="form-label fw-semibold">Apellido</label>
                        <asp:TextBox ID="txtApellido" runat="server" CssClass="form-control" MaxLength="100" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtApellido"
                            ValidationGroup="Editar" CssClass="text-danger small"
                            ErrorMessage="El apellido es obligatorio." Display="Dynamic" />
                    </div>
                    <div class="col-12">
                        <label class="form-label fw-semibold">Teléfono <span class="text-muted fw-normal">(opcional)</span></label>
                        <asp:TextBox ID="txtTelefono" runat="server" CssClass="form-control" MaxLength="20" />
                    </div>
                </div>
                <div class="mt-3">
                    <asp:Button ID="btnGuardarDatos" runat="server" Text="Guardar cambios"
                        CssClass="btn-r btn-primary-r" OnClick="btnGuardarDatos_Click"
                        ValidationGroup="Editar" />
                </div>
            </div>

            <%-- Cambiar contraseña --%>
            <div class="card-r p-4">
                <h5 class="fw-semibold mb-3">Cambiar contraseña</h5>
                <asp:Label ID="lblErrorPassword" runat="server" CssClass="alert alert-danger d-block" Visible="false" />
                <div class="row g-3">
                    <div class="col-12">
                        <label class="form-label fw-semibold">Contraseña actual</label>
                        <asp:TextBox ID="txtPasswordActual" runat="server" CssClass="form-control" TextMode="Password" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtPasswordActual"
                            ValidationGroup="Password" CssClass="text-danger small"
                            ErrorMessage="Ingresá tu contraseña actual." Display="Dynamic" />
                    </div>
                    <div class="col-12">
                        <label class="form-label fw-semibold">Nueva contraseña</label>
                        <asp:TextBox ID="txtPasswordNueva" runat="server" CssClass="form-control" TextMode="Password" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtPasswordNueva"
                            ValidationGroup="Password" CssClass="text-danger small"
                            ErrorMessage="Ingresá la nueva contraseña." Display="Dynamic" />
                    </div>
                    <div class="col-12">
                        <label class="form-label fw-semibold">Confirmar contraseña</label>
                        <asp:TextBox ID="txtPasswordConfirm" runat="server" CssClass="form-control" TextMode="Password" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtPasswordConfirm"
                            ValidationGroup="Password" CssClass="text-danger small"
                            ErrorMessage="Confirmá la nueva contraseña." Display="Dynamic" />
                    </div>
                </div>
                <div class="mt-3">
                    <asp:Button ID="btnCambiarPassword" runat="server" Text="Cambiar contraseña"
                        CssClass="btn-r btn-primary-r" OnClick="btnCambiarPassword_Click"
                        ValidationGroup="Password" />
                </div>
            </div>

        </div>
    </div>

</asp:Content>

