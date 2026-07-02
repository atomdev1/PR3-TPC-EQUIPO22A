<%@ Page Title="Beneficios" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Beneficios.aspx.cs" Inherits="WebApp.Beneficios" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="d-flex align-items-center mb-4">
        <div>
            <h2 class="mb-0">Beneficios de fidelidad</h2>
            <small class="text-muted">Las reglas con las que premiás a tus clientes frecuentes</small>
        </div>
        <asp:Button ID="btnNuevo" runat="server" CssClass="btn-r btn-primary-r ms-auto"
            Text="+ Nuevo beneficio" OnClick="btnNuevo_Click" CausesValidation="false" />
    </div>

    <%-- Banner sistema de fidelidad --%>
    <div class="banner-soft d-flex align-items-start gap-3 mb-4">
        <div class="kpi-ico flex-shrink-0">🏆</div>
        <div>
            <div class="fw-semibold mb-1">¿Cómo funcionan los beneficios?</div>
            <div class="text-muted" style="font-size:0.875rem">
                Cada beneficio es una regla del complejo: cuando un cliente alcanza la cantidad de reservas
                indicada, se le otorga automáticamente un cupón con el descuento configurado.
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

    <%-- Grid de beneficios --%>
    <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
        <asp:Repeater ID="rptBeneficios" runat="server" OnItemCommand="rptBeneficios_ItemCommand">
            <ItemTemplate>
                <div class="col">
                    <div class='<%# "card-r card-hover h-100" + ((bool)Eval("Activo") ? "" : " is-inactive") %>'>
                        <div class="card-r-pad d-flex flex-column">

                            <%-- Header: badge descuento + nombre + badge estado --%>
                            <div class="d-flex align-items-start gap-3 mb-3">
                                <asp:Panel runat="server" CssClass="kpi-ico flex-shrink-0">
                                    <asp:Label runat="server" Text='<%# GetBadgeSymbol(Eval("TipoDescuento")) %>' />
                                </asp:Panel>
                                <div class="flex-grow-1 min-w-0">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <asp:Label runat="server" CssClass="fw-semibold text-truncate" Text='<%# Eval("Nombre") %>' />
                                        <asp:Label runat="server"
                                            CssClass='<%# "tag flex-shrink-0 " + GetEstadoBadgeClass(Eval("Activo")) %>'
                                            Text='<%# GetEstadoNombre(Eval("Activo")) %>' />
                                    </div>
                                    <asp:Label runat="server" CssClass="text-soft small d-block mt-1"
                                        Text='<%# GetTipoNombre(Eval("TipoDescuento")) %>' />
                                </div>
                            </div>

                            <%-- Valor --%>
                            <asp:Label runat="server"
                                CssClass="price-tag d-block mb-1"
                                Text='<%# FormatearValor(Eval("TipoDescuento"), Eval("ValorDescuento")) %>' />

                            <%-- Descripción --%>
                            <asp:Label runat="server" CssClass="text-soft small d-block mb-3"
                                Text='<%# Eval("Descripcion") %>' />

                            <%-- Metadatos --%>
                            <div class="d-flex flex-column gap-1 mb-3">
                                <asp:Label runat="server" Text='<%# "🎯 Requiere " + Eval("ReservasRequeridas") + " reservas" %>' />
                                <asp:Label runat="server" Text='<%# FormatearValidez(Eval("DiasValidez")) %>' />
                            </div>

                            <%-- Acciones --%>
                            <div class="d-flex gap-2 mt-auto pt-3" style="border-top: 1px solid var(--border-subtle)">
                                <asp:LinkButton ID="btnEditar" runat="server"
                                    CommandName="Editar"
                                    CommandArgument='<%# Eval("IdBeneficio") %>'
                                    CssClass="btn-r btn-sm-r btn-ghost-r w-100">
                                    Editar
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnBaja" runat="server"
                                    CommandName="Baja"
                                    CommandArgument='<%# Eval("IdBeneficio") %>'
                                    CssClass="btn btn-sm btn-outline-danger"
                                    Visible='<%# (bool)Eval("Activo") %>'>
                                    Dar de baja
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnReactivar" runat="server"
                                    CommandName="Reactivar"
                                    CommandArgument='<%# Eval("IdBeneficio") %>'
                                    CssClass="btn btn-sm btn-outline-success"
                                    Visible='<%# !(bool)Eval("Activo") %>'>
                                    Reactivar
                                </asp:LinkButton>
                            </div>

                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>

    <%-- Modal Nuevo / Editar Beneficio --%>
    <div class="modal fade" id="modalBeneficio" tabindex="-1" aria-labelledby="modalBeneficioLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="modalBeneficioLabel">Nuevo beneficio</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                </div>
                <div class="modal-body">
                    <asp:UpdatePanel ID="upBeneficio" runat="server">
                        <ContentTemplate>
                            <asp:HiddenField ID="hfIdBeneficio" runat="server" />
                            <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger d-block" Visible="false" />
                            <div class="row g-3">

                                <div class="col-md-8">
                                    <label class="form-label fw-semibold">Nombre</label>
                                    <asp:TextBox ID="txtNombre" runat="server" CssClass="form-control" placeholder="Ej: Cliente Plata" MaxLength="50" />
                                    <asp:RequiredFieldValidator ID="rfvNombre" runat="server"
                                        ControlToValidate="txtNombre" ValidationGroup="Beneficio"
                                        CssClass="text-danger small" ErrorMessage="El nombre es obligatorio." Display="Dynamic" />
                                </div>

                                <div class="col-md-4">
                                    <label class="form-label fw-semibold">Reservas requeridas</label>
                                    <asp:TextBox ID="txtReservasRequeridas" runat="server" CssClass="form-control" TextMode="Number" placeholder="10" />
                                    <asp:RequiredFieldValidator ID="rfvReservas" runat="server"
                                        ControlToValidate="txtReservasRequeridas" ValidationGroup="Beneficio"
                                        CssClass="text-danger small" ErrorMessage="Campo obligatorio." Display="Dynamic" />
                                    <asp:RangeValidator ID="rvReservas" runat="server"
                                        ControlToValidate="txtReservasRequeridas" ValidationGroup="Beneficio"
                                        CssClass="text-danger small" Display="Dynamic"
                                        MinimumValue="1" MaximumValue="9999" Type="Integer"
                                        ErrorMessage="Debe ser entre 1 y 9999." />
                                </div>

                                <div class="col-md-4">
                                    <label class="form-label fw-semibold">Tipo de descuento</label>
                                    <asp:DropDownList ID="ddlTipoDescuento" runat="server" CssClass="form-select"
                                        AutoPostBack="true" OnSelectedIndexChanged="ddlTipoDescuento_SelectedIndexChanged">
                                        <asp:ListItem Value="1">Porcentaje (%)</asp:ListItem>
                                        <asp:ListItem Value="2">Reserva gratis</asp:ListItem>
                                    </asp:DropDownList>
                                </div>

                                <div class="col-md-4">
                                    <label class="form-label fw-semibold">Valor del descuento</label>
                                    <asp:TextBox ID="txtValorDescuento" runat="server" CssClass="form-control" TextMode="Number" placeholder="15" />
                                </div>

                                <div class="col-md-4">
                                    <label class="form-label fw-semibold">Días de validez</label>
                                    <asp:TextBox ID="txtDiasValidez" runat="server" CssClass="form-control" TextMode="Number" placeholder="30" />
                                    <small class="text-muted d-block">Cuántos días dura el cupón desde que se otorga.</small>
                                </div>

                                <div class="col-12">
                                    <label class="form-label fw-semibold">Descripción</label>
                                    <asp:TextBox ID="txtDescripcion" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2"
                                        placeholder="Ej: 15% off al llegar a 10 reservas" MaxLength="300" />
                                </div>

                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-r btn-ghost-r" data-bs-dismiss="modal">Cancelar</button>
                    <asp:Button ID="btnGuardar" runat="server" Text="Guardar beneficio"
                        CssClass="btn-r btn-primary-r" OnClick="btnGuardar_Click" ValidationGroup="Beneficio" />
                </div>
            </div>
        </div>
    </div>

</asp:Content>
