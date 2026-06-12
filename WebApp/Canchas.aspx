<%@ Page Title="Canchas" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Canchas.aspx.cs" Inherits="WebApp.Canchas" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="d-flex align-items-center mb-4">
        <div>
            <h2 class="mb-0">Canchas</h2>
            <small class="text-muted">
                <asp:Label ID="lblTotal" runat="server" />
            </small>
        </div>
        <asp:Button ID="btnNueva" runat="server" CssClass="btn btn-success ms-auto"
            Text="+ Nueva cancha" OnClick="btnNueva_Click" CausesValidation="false" />
    </div>

    <%-- Confirmación de eliminación --%>
    <asp:Panel ID="pnlConfirmarBaja" runat="server" Visible="false"
        CssClass="alert alert-warning d-flex justify-content-between align-items-center mb-4">
        <asp:Label ID="lblConfirmarBaja" runat="server" CssClass="mb-0" />
        <div class="d-flex gap-2">
            <asp:Button ID="btnConfirmarBaja" runat="server" Text="Sí, eliminar"
                CssClass="btn btn-sm btn-danger" OnClick="btnConfirmarBaja_Click" CausesValidation="false" />
            <asp:Button ID="btnCancelarBaja" runat="server" Text="Cancelar"
                CssClass="btn btn-sm btn-outline-secondary" OnClick="btnCancelarBaja_Click" CausesValidation="false" />
        </div>
    </asp:Panel>
    <asp:HiddenField ID="hfBajaId" runat="server" />

    <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
        <asp:Repeater ID="rptCanchas" runat="server" OnItemCommand="rptCanchas_ItemCommand">
            <ItemTemplate>
                <div class="col">
                    <div class="card h-100 app-card app-card-hover">
                        <div class="card-body d-flex flex-column p-3">

                            <%-- Encabezado: ícono + nombre + badge --%>
                            <div class="d-flex align-items-start gap-3 mb-3">
                                <asp:Panel runat="server" CssClass="cancha-sport-icon"
                                    Style='<%# "border-left: 3px solid " + GetDeporteAccent(Eval("Deporte.Nombre")) %>'>
                                    <asp:Label runat="server" Text='<%# GetDeporteEmoji(Eval("Deporte.Nombre")) %>' />
                                </asp:Panel>
                                <div class="flex-grow-1 min-w-0">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <asp:Label runat="server" CssClass="mb-0 fw-semibold text-truncate me-2"
                                            Text='<%# Eval("NombreFantasia") %>' />
                                        <asp:Label runat="server"
                                            CssClass='<%# "badge fw-normal flex-shrink-0 " + ((bool)Eval("Activa") ? "text-success bg-success-subtle" : "text-warning bg-warning-subtle") %>'
                                            Text='<%# (bool)Eval("Activa") ? "Disponible" : "Mantenimiento" %>' />
                                    </div>
                                    <asp:Label runat="server" CssClass="cancha-meta d-block"
                                        Text='<%# Eval("Deporte.Nombre") %>' />
                                </div>
                            </div>

                            <%-- Descripción --%>
                            <asp:Label runat="server" CssClass="cancha-meta d-block mb-3"
                                Style="line-height:1.5" Text='<%# Eval("Descripcion") %>' />

                            <%-- Precio + capacidad --%>
                            <div class="d-flex justify-content-between align-items-center pt-2 cancha-divider mt-auto mb-3">
                                <asp:Label runat="server" CssClass="cancha-precio mt-2"
                                    Text='<%# FormatearPrecio(Eval("Precio")) %>' />
                                <asp:Label runat="server" CssClass="cancha-meta mt-2"
                                    Text='<%# Eval("CapacidadJugadores") + " jugadores" %>' />
                            </div>

                            <%-- Acciones --%>
                            <div class="d-flex gap-2">
                                <asp:LinkButton ID="btnEditar" runat="server"
                                    CommandName="Editar"
                                    CommandArgument='<%# Eval("IdCancha") %>'
                                    CssClass="btn btn-sm btn-light btn-accion w-100">
                                    Editar
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnEliminar" runat="server"
                                    CommandName="Eliminar"
                                    CommandArgument='<%# Eval("IdCancha") %>'
                                    CssClass="btn btn-sm btn-outline-danger btn-accion">
                                    Eliminar
                                </asp:LinkButton>
                            </div>

                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>

    <%-- Modal Nueva Cancha --%>
    <div class="modal fade" id="modalNuevaCancha" tabindex="-1" aria-labelledby="modalNuevaCanchaLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <asp:Label ID="lblTituloModalCancha" runat="server" CssClass="modal-title h5" Text="Nueva cancha" />
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hfIdCancha" runat="server" />
                    <asp:Label ID="lblErrorCancha" runat="server" CssClass="alert alert-danger d-block" Visible="false" />
                    <div class="row g-3">

                        <div class="col-md-8">
                            <label class="form-label fw-semibold">Nombre de fantasía</label>
                            <asp:TextBox ID="txtNombre" runat="server" CssClass="form-control" placeholder="Ej: Cancha Tenis Central" MaxLength="100" />
                            <asp:RequiredFieldValidator ID="rfvNombre" runat="server"
                                ControlToValidate="txtNombre" ValidationGroup="NuevaCancha"
                                CssClass="text-danger small" ErrorMessage="El nombre es obligatorio." Display="Dynamic" />
                        </div>

                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Número</label>
                            <asp:TextBox ID="txtNumero" runat="server" CssClass="form-control" TextMode="Number" placeholder="1" />
                            <asp:RequiredFieldValidator ID="rfvNumero" runat="server"
                                ControlToValidate="txtNumero" ValidationGroup="NuevaCancha"
                                CssClass="text-danger small" ErrorMessage="El número es obligatorio." Display="Dynamic" />
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Deporte</label>
                            <asp:DropDownList ID="ddlDeporte" runat="server" CssClass="form-select" />
                            <asp:RequiredFieldValidator ID="rfvDeporte" runat="server"
                                ControlToValidate="ddlDeporte" InitialValue="0" ValidationGroup="NuevaCancha"
                                CssClass="text-danger small" ErrorMessage="Seleccioná un deporte." Display="Dynamic" />
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Capacidad de jugadores</label>
                            <asp:TextBox ID="txtCapacidad" runat="server" CssClass="form-control" TextMode="Number" placeholder="10" />
                            <asp:RequiredFieldValidator ID="rfvCapacidad" runat="server"
                                ControlToValidate="txtCapacidad" ValidationGroup="NuevaCancha"
                                CssClass="text-danger small" ErrorMessage="La capacidad es obligatoria." Display="Dynamic" />
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Precio por hora ($)</label>
                            <asp:TextBox ID="txtPrecio" runat="server" CssClass="form-control" TextMode="Number" placeholder="5000" />
                            <asp:RequiredFieldValidator ID="rfvPrecio" runat="server"
                                ControlToValidate="txtPrecio" ValidationGroup="NuevaCancha"
                                CssClass="text-danger small" ErrorMessage="El precio es obligatorio." Display="Dynamic" />
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Monto de seña ($)</label>
                            <asp:TextBox ID="txtSena" runat="server" CssClass="form-control" TextMode="Number" placeholder="2000" />
                            <asp:RequiredFieldValidator ID="rfvSena" runat="server"
                                ControlToValidate="txtSena" ValidationGroup="NuevaCancha"
                                CssClass="text-danger small" ErrorMessage="El monto de seña es obligatorio." Display="Dynamic" />
                        </div>

                        <div class="col-12">
                            <label class="form-label fw-semibold">Descripción</label>
                            <asp:TextBox ID="txtDescripcion" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"
                                placeholder="Ej: Césped sintético · Iluminación · Techada" MaxLength="300" />
                        </div>

                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <asp:Button ID="btnGuardarCancha" runat="server" Text="Guardar cancha"
                        CssClass="btn btn-success" OnClick="btnGuardarCancha_Click" ValidationGroup="NuevaCancha" />
                </div>
            </div>
        </div>
    </div>

</asp:Content>
