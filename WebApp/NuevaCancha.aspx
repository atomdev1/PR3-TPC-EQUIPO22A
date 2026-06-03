<%@ Page Title="Nueva Cancha" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="NuevaCancha.aspx.cs" Inherits="WebApp.NuevaCancha" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="d-flex align-items-center mb-4">
        <div>
            <h2 class="mb-0">Nueva cancha</h2>
            <small class="text-muted">Completá los datos de la cancha</small>
        </div>
        <asp:HyperLink ID="lnkVolver" runat="server" NavigateUrl="~/Canchas.aspx"
            CssClass="btn btn-outline-secondary ms-auto">
            &larr; Volver
        </asp:HyperLink>
    </div>

    <div class="card shadow-sm" style="max-width: 680px;">
        <div class="card-body p-4">

            <div class="row g-3">

                <div class="col-md-8">
                    <label class="form-label fw-semibold">Nombre de fantasía</label>
                    <asp:TextBox ID="txtNombre" runat="server" CssClass="form-control" placeholder="Ej: Cancha Tenis Central" MaxLength="100" />
                    <asp:RequiredFieldValidator ID="rfvNombre" runat="server"
                        ControlToValidate="txtNombre"
                        CssClass="text-danger small"
                        ErrorMessage="El nombre es obligatorio."
                        Display="Dynamic" />
                </div>

                <div class="col-md-4">
                    <label class="form-label fw-semibold">Número</label>
                    <asp:TextBox ID="txtNumero" runat="server" CssClass="form-control" TextMode="Number" placeholder="1" />
                    <asp:RequiredFieldValidator ID="rfvNumero" runat="server"
                        ControlToValidate="txtNumero"
                        CssClass="text-danger small"
                        ErrorMessage="El número es obligatorio."
                        Display="Dynamic" />
                </div>

                <div class="col-md-6">
                    <label class="form-label fw-semibold">Deporte</label>
                    <asp:DropDownList ID="ddlDeporte" runat="server" CssClass="form-select" />
                    <asp:RequiredFieldValidator ID="rfvDeporte" runat="server"
                        ControlToValidate="ddlDeporte"
                        InitialValue="0"
                        CssClass="text-danger small"
                        ErrorMessage="Seleccioná un deporte."
                        Display="Dynamic" />
                </div>

                <div class="col-md-6">
                    <label class="form-label fw-semibold">Capacidad de jugadores</label>
                    <asp:TextBox ID="txtCapacidad" runat="server" CssClass="form-control" TextMode="Number" placeholder="10" />
                    <asp:RequiredFieldValidator ID="rfvCapacidad" runat="server"
                        ControlToValidate="txtCapacidad"
                        CssClass="text-danger small"
                        ErrorMessage="La capacidad es obligatoria."
                        Display="Dynamic" />
                </div>

                <div class="col-md-6">
                    <label class="form-label fw-semibold">Precio por hora ($)</label>
                    <asp:TextBox ID="txtPrecio" runat="server" CssClass="form-control" TextMode="Number" placeholder="5000" />
                    <asp:RequiredFieldValidator ID="rfvPrecio" runat="server"
                        ControlToValidate="txtPrecio"
                        CssClass="text-danger small"
                        ErrorMessage="El precio es obligatorio."
                        Display="Dynamic" />
                </div>

                <div class="col-md-6">
                    <label class="form-label fw-semibold">Monto de seña ($)</label>
                    <asp:TextBox ID="txtSena" runat="server" CssClass="form-control" TextMode="Number" placeholder="2000" />
                    <asp:RequiredFieldValidator ID="rfvSena" runat="server"
                        ControlToValidate="txtSena"
                        CssClass="text-danger small"
                        ErrorMessage="El monto de seña es obligatorio."
                        Display="Dynamic" />
                </div>

                <div class="col-12">
                    <label class="form-label fw-semibold">Descripción</label>
                    <asp:TextBox ID="txtDescripcion" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"
                        placeholder="Ej: Césped sintético · Iluminación · Techada" MaxLength="300" />
                </div>

            </div>

            <div class="d-flex gap-2 mt-4">
                <asp:Button ID="btnGuardar" runat="server" Text="Guardar cancha"
                    CssClass="btn btn-success" OnClick="btnGuardar_Click" />
                <asp:HyperLink ID="lnkCancelar" runat="server" NavigateUrl="~/Canchas.aspx"
                    CssClass="btn btn-outline-secondary">
                    Cancelar
                </asp:HyperLink>
            </div>

        </div>
    </div>

</asp:Content>
