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
        <asp:Button ID="btnNueva" runat="server" CssClass="btn-r btn-primary-r ms-auto"
            Text="+ Nueva cancha" OnClick="btnNueva_Click" CausesValidation="false" />
    </div>

    <%-- Filtros --%>
    <div class="card-r mb-4 p-3">
        <div class="row g-2 align-items-end">
            <div class="col-md-4">
                <label class="form-label small fw-semibold mb-1">Deporte</label>
                 <asp:DropDownList ID="ddlFiltroDeporte" runat="server"
                    CssClass="form-select form-select-sm"
                    AutoPostBack="true" OnSelectedIndexChanged="Filtrar" />
            </div>
            <div class="col-md-4">
                <label class="form-label small fw-semibold mb-1">Estado</label>
                <asp:DropDownList ID="ddlFiltroEstado" runat="server"
                    CssClass="form-select form-select-sm"
                    AutoPostBack="true" OnSelectedIndexChanged="Filtrar" />
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

    <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
        <asp:Repeater ID="rptCanchas" runat="server" OnItemCommand="rptCanchas_ItemCommand">
            <ItemTemplate>
                <div class="col">
                    <div class='<%# "card-r card-hover h-100" + ((bool)Eval("Activa") ? "" : " is-inactive") %>'>
                        <div class="card-r-pad d-flex flex-column">

                            <%-- Encabezado: ícono + nombre + badge --%>
                            <div class="d-flex align-items-start gap-3 mb-3">
                                <asp:Panel runat="server" CssClass="sport-ico"
                                    Style='<%# "border-left: 3px solid " + GetDeporteAccent(Eval("Deporte.Nombre")) %>'>
                                    <asp:Label runat="server" Text='<%# GetDeporteEmoji(Eval("Deporte.Nombre")) %>' />
                                </asp:Panel>
                                <div class="flex-grow-1 min-w-0">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <asp:Label runat="server" CssClass="mb-0 fw-semibold text-truncate me-2"
                                            Text='<%# Eval("NombreFantasia") %>' />
                                        <asp:Label runat="server"
                                            CssClass='<%# "tag flex-shrink-0 " + ((bool)Eval("Activa") ? "tag-ok" : "tag-warn") %>'
                                            Text='<%# (bool)Eval("Activa") ? "Disponible" : "Mantenimiento" %>' />
                                    </div>
                                    <asp:Label runat="server" CssClass="text-soft small d-block"
                                        Text='<%# Eval("Deporte.Nombre") %>' />
                                </div>
                            </div>

                            <%-- Descripción --%>
                            <asp:Label runat="server" CssClass="text-soft small d-block mb-3"
                                Style="line-height:1.5" Text='<%# Eval("Descripcion") %>' />

                            <%-- Precio + capacidad --%>
                            <div class="d-flex justify-content-between align-items-center pt-2 mt-auto mb-3" style="border-top: 1px solid var(--border-subtle)">
                                <asp:Label runat="server" CssClass="price-tag mt-2"
                                    Text='<%# FormatearPrecio(Eval("Precio")) %>' />
                                <asp:Label runat="server" CssClass="text-soft small mt-2"
                                    Text='<%# Eval("CapacidadJugadores") + " jugadores" %>' />
                            </div>

                            <%-- Acciones --%>
                            <div class="d-flex gap-2">
                                <asp:LinkButton ID="btnEditar" runat="server"
                                    CommandName="Editar"
                                    CommandArgument='<%# Eval("IdCancha") %>'
                                    CssClass="btn-r btn-sm-r btn-ghost-r w-100">
                                    Editar
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnBaja" runat="server"
                                    CommandName="Baja"
                                    CommandArgument='<%# Eval("IdCancha") %>'
                                    CssClass="btn btn-sm btn-outline-danger"
                                    Visible='<%# (bool)Eval("Activa") %>'>
                                    Dar de baja
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnReactivar" runat="server"
                                    CommandName="Reactivar"
                                    CommandArgument='<%# Eval("IdCancha") %>'
                                    CssClass="btn btn-sm btn-outline-success"
                                    Visible='<%# !(bool)Eval("Activa") %>'>
                                    Reactivar
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
                            <asp:RangeValidator ID="rvNumero" runat="server"
                                ControlToValidate="txtNumero" ValidationGroup="NuevaCancha"
                                CssClass="text-danger small" Display="Dynamic"
                                MinimumValue="1" MaximumValue="9999" Type="Integer"
                                ErrorMessage="El número debe estar entre 1 y 9999." />
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
                            <asp:RangeValidator ID="rvCapacidad" runat="server"
                                ControlToValidate="txtCapacidad" ValidationGroup="NuevaCancha"
                                CssClass="text-danger small" Display="Dynamic"
                                MinimumValue="1" MaximumValue="100" Type="Integer"
                                ErrorMessage="La capacidad debe estar entre 1 y 100." />
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Precio por hora ($)</label>
                            <asp:TextBox ID="txtPrecio" runat="server" CssClass="form-control" TextMode="Number" placeholder="5000" />
                            <asp:RequiredFieldValidator ID="rfvPrecio" runat="server"
                                ControlToValidate="txtPrecio" ValidationGroup="NuevaCancha"
                                CssClass="text-danger small" ErrorMessage="El precio es obligatorio." Display="Dynamic" />
                            <asp:RangeValidator ID="rvPrecio" runat="server"
                                ControlToValidate="txtPrecio" ValidationGroup="NuevaCancha"
                                CssClass="text-danger small" Display="Dynamic"
                                MinimumValue="1" MaximumValue="9999999" Type="Double"
                                ErrorMessage="El precio debe ser mayor a 0." />
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Monto de seña ($)</label>
                            <asp:TextBox ID="txtSena" runat="server" CssClass="form-control" TextMode="Number" placeholder="2000" />
                            <asp:RequiredFieldValidator ID="rfvSena" runat="server"
                                ControlToValidate="txtSena" ValidationGroup="NuevaCancha"
                                CssClass="text-danger small" ErrorMessage="El monto de seña es obligatorio." Display="Dynamic" />
                            <asp:RangeValidator ID="rvSena" runat="server"
                                ControlToValidate="txtSena" ValidationGroup="NuevaCancha"
                                CssClass="text-danger small" Display="Dynamic"
                                MinimumValue="0" MaximumValue="9999999" Type="Double"
                                ErrorMessage="El monto de seña no puede ser negativo." />
                        </div>

                        <div class="col-12">
                            <label class="form-label fw-semibold">Descripción</label>
                            <asp:TextBox ID="txtDescripcion" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"
                                placeholder="Ej: Césped sintético · Iluminación · Techada" MaxLength="300" />
                        </div>

                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-r btn-ghost-r" data-bs-dismiss="modal">Cancelar</button>
                    <asp:Button ID="btnGuardarCancha" runat="server" Text="Guardar cancha"
                        CssClass="btn-r btn-primary-r" OnClick="btnGuardarCancha_Click" ValidationGroup="NuevaCancha" />
                </div>
            </div>
        </div>
    </div>

</asp:Content>
