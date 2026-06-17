<%@ Page Title="Deportes" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Deportes.aspx.cs" Inherits="WebApp.Deportes" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="d-flex align-items-center mb-4">
        <div>
            <h2 class="mb-0">Deportes</h2>
            <small class="text-muted">
                <asp:Label ID="lblTotal" runat="server" />
            </small>
        </div>
        <asp:Button ID="btnNuevo" runat="server" CssClass="btn-r btn-primary-r ms-auto"
            Text="+ Nuevo deporte" OnClick="btnNuevo_Click" CausesValidation="false" />
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
        <asp:Repeater ID="rptDeportes" runat="server" OnItemCommand="rptDeportes_ItemCommand">
            <ItemTemplate>
                <div class="col">
                    <div class='<%# "card-r card-hover h-100" + ((bool)Eval("Activa") ? "" : " is-inactive") %>'>
                        <div class="card-r-pad d-flex flex-column">

                            <%-- Encabezado: ícono + nombre + badge --%>
                            <div class="d-flex align-items-start gap-3 mb-3">
                                <asp:Panel runat="server" CssClass="sport-ico"
                                    Style='<%# "border-left: 3px solid " + GetDeporteAccent(Eval("Nombre")) %>'>
                                    <asp:Label runat="server" Text='<%# GetDeporteEmoji(Eval("Nombre")) %>' />
                                </asp:Panel>
                                <div class="flex-grow-1 min-w-0">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <asp:Label runat="server" CssClass="mb-0 fw-semibold text-truncate me-2"
                                            Text='<%# Eval("Nombre") %>' />
                                        <asp:Label runat="server"
                                            CssClass='<%# "tag flex-shrink-0 " + ((bool)Eval("Activa") ? "tag-ok" : "tag-warn") %>'
                                            Text='<%# (bool)Eval("Activa") ? "Activo" : "Inactivo" %>' />
                                    </div>
                                    <asp:Label runat="server" CssClass="text-soft small d-block"
                                        Text='<%# FormatearDuracion(Eval("DuracionMinutos")) %>' />
                                </div>
                            </div>

                            <%-- Acciones --%>
                            <div class="d-flex gap-2 mt-auto">
                                <asp:LinkButton ID="btnEditar" runat="server"
                                    CommandName="Editar"
                                    CommandArgument='<%# Eval("IdDeporte") %>'
                                    CssClass="btn-r btn-sm-r btn-ghost-r w-100">
                                    Editar
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnBaja" runat="server"
                                    CommandName="Baja"
                                    CommandArgument='<%# Eval("IdDeporte") %>'
                                    CssClass="btn btn-sm btn-outline-danger"
                                    Visible='<%# (bool)Eval("Activa") %>'>
                                    Dar de baja
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnReactivar" runat="server"
                                    CommandName="Reactivar"
                                    CommandArgument='<%# Eval("IdDeporte") %>'
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

    <%-- Modal Nuevo Deporte --%>
    <div class="modal fade" id="modalNuevoDeporte" tabindex="-1" aria-labelledby="modalNuevoDeporteLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <asp:Label ID="lblTituloModalDeporte" runat="server" CssClass="modal-title h5" Text="Nuevo deporte" />
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hfIdDeporte" runat="server" />
                    <asp:Label ID="lblErrorDeporte" runat="server" CssClass="alert alert-danger d-block" Visible="false" />
                    <div class="row g-3">

                        <div class="col-md-7">
                            <label class="form-label fw-semibold">Nombre</label>
                            <asp:TextBox ID="txtNombre" runat="server" CssClass="form-control" placeholder="Ej: Fútbol" MaxLength="50" />
                            <asp:RequiredFieldValidator ID="rfvNombre" runat="server"
                                ControlToValidate="txtNombre" ValidationGroup="NuevoDeporte"
                                CssClass="text-danger small" ErrorMessage="El nombre es obligatorio." Display="Dynamic" />
                        </div>

                        <div class="col-md-5">
                            <label class="form-label fw-semibold">Duración (minutos)</label>
                            <asp:TextBox ID="txtDuracion" runat="server" CssClass="form-control" TextMode="Number" placeholder="60" />
                            <asp:RequiredFieldValidator ID="rfvDuracion" runat="server"
                                ControlToValidate="txtDuracion" ValidationGroup="NuevoDeporte"
                                CssClass="text-danger small" ErrorMessage="La duración es obligatoria." Display="Dynamic" />
                            <asp:RangeValidator ID="rvDuracion" runat="server"
                                ControlToValidate="txtDuracion" ValidationGroup="NuevoDeporte"
                                MinimumValue="1" MaximumValue="600" Type="Integer"
                                CssClass="text-danger small" ErrorMessage="La duración debe estar entre 1 y 600 minutos." Display="Dynamic" />
                        </div>

                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-r btn-ghost-r" data-bs-dismiss="modal">Cancelar</button>
                    <asp:Button ID="btnGuardarDeporte" runat="server" Text="Guardar deporte"
                        CssClass="btn-r btn-primary-r" OnClick="btnGuardarDeporte_Click" ValidationGroup="NuevoDeporte" />
                </div>
            </div>
        </div>
    </div>

</asp:Content>
