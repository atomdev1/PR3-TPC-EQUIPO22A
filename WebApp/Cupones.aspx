<%@ Page Title="Cupones" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Cupones.aspx.cs" Inherits="WebApp.Cupones" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="d-flex align-items-center mb-4">
        <div>
            <h2 class="mb-0">Cupones de fidelidad</h2>
            <small class="text-muted">Recompensá a tus clientes frecuentes</small>
        </div>
        <button type="button" class="btn btn-success ms-auto"
            data-bs-toggle="modal" data-bs-target="#modalNuevoCupon"
            onclick="nuevoCupon()">
            + Nuevo cupón
        </button>
    </div>

    <%-- Banner sistema de fidelidad --%>
    <div class="fidelidad-banner d-flex align-items-start gap-3 mb-4">
        <div class="fidelidad-icon">🎫</div>
        <div>
            <div class="fw-semibold mb-1">Sistema de fidelidad</div>
            <div class="text-muted" style="font-size:0.875rem">
                Configurá cupones que se otorgan automáticamente cuando un cliente alcanza cierta cantidad de reservas.
                Podés ofrecer reservas con descuento o gratis.
            </div>
        </div>
    </div>

    <%-- Grid de cupones --%>
    <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
        <asp:Repeater ID="rptCupones" runat="server" OnItemCommand="rptCupones_ItemCommand">
            <ItemTemplate>
                <div class="col">
                    <div class="card h-100 app-card app-card-hover">
                        <div class="card-body d-flex flex-column p-3">

                            <%-- Header: badge descuento + código + badge estado --%>
                            <div class="d-flex align-items-start gap-3 mb-3">
                                <asp:Panel runat="server" CssClass='<%# "cupon-descuento-badge " + GetBadgeClass(Eval("TipoDescuento")) %>'>
                                    <asp:Label runat="server" Text='<%# GetBadgeSymbol(Eval("TipoDescuento")) %>' />
                                </asp:Panel>
                                <div class="flex-grow-1 min-w-0">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div class="d-flex align-items-center gap-2">
                                            <asp:Label runat="server" CssClass="cupon-codigo" Text='<%# Eval("Codigo") %>' />
                                            <button type="button" class="btn-copy-code"
                                                onclick='copiarCodigo(this, "<%# Eval("Codigo") %>")'>
                                                Copiar
                                            </button>
                                        </div>
                                        <asp:Label runat="server"
                                            CssClass='<%# "badge fw-normal flex-shrink-0 " + GetEstadoBadgeClass(Eval("Estado")) %>'
                                            Text='<%# Eval("Estado").ToString() %>' />
                                    </div>
                                    <asp:Label runat="server" CssClass="cupon-tipo-label d-block mt-1"
                                        Text='<%# GetTipoNombre(Eval("TipoDescuento")) %>' />
                                </div>
                            </div>

                            <%-- Valor --%>
                            <asp:Label runat="server"
                                CssClass='<%# "cupon-valor d-block mb-1 " + GetBadgeClass(Eval("TipoDescuento")) %>'
                                Text='<%# FormatearValor(Eval("TipoDescuento"), Eval("ValorDescuento")) %>' />

                            <%-- Descripción --%>
                            <asp:Label runat="server" CssClass="cupon-descripcion d-block mb-3"
                                Text='<%# Eval("Descripcion") %>' />

                            <%-- Metadatos --%>
                            <div class="d-flex flex-column gap-1 mb-3 cupon-meta">
                                <asp:Label runat="server" CssClass="fw-semibold text-dark"
                                    Text='<%# "👤 " + Eval("Usuario.Nombre") + " " + Eval("Usuario.Apellido") %>' />
                                <asp:Label runat="server" Text='<%# FormatearMeta("reservas", Eval("ReservasRequeridas")) %>' />
                                <asp:Label runat="server" Text='<%# FormatearMeta("fecha", Eval("ValidoHasta")) %>' />
                                <asp:Label runat="server" Text='<%# FormatearMeta("usos", Eval("UsosActuales"), Eval("LimiteUsos")) %>' />
                            </div>

                            <%-- Acciones --%>
                            <div class="d-flex gap-2 mt-auto cupon-divider pt-3">
                                <asp:LinkButton ID="btnEditar" runat="server"
                                    CommandName="Editar"
                                    CommandArgument='<%# Eval("IdCupon") %>'
                                    CssClass="btn btn-sm btn-light btn-accion w-100">
                                    Editar
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnEliminar" runat="server"
                                    CommandName="Eliminar"
                                    CommandArgument='<%# Eval("IdCupon") %>'
                                    CssClass="btn btn-sm btn-outline-danger btn-accion"
                                    OnClientClick="return confirm('¿Eliminar este cupón?');">
                                    Eliminar
                                </asp:LinkButton>
                            </div>

                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>

    <%-- Modal Nuevo Cupón --%>
    <div class="modal fade" id="modalNuevoCupon" tabindex="-1" aria-labelledby="modalNuevoCuponLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="modalNuevoCuponLabel">Nuevo cupón</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hfIdCupon" runat="server" />
                    <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger d-block" Visible="false" />
                    <div class="row g-3">

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Código</label>
                            <asp:TextBox ID="txtCodigo" runat="server" CssClass="form-control" placeholder="Ej: TP-PROMO010" MaxLength="50" />
                            <asp:RequiredFieldValidator ID="rfvCodigo" runat="server"
                                ControlToValidate="txtCodigo" ValidationGroup="NuevoCupon"
                                CssClass="text-danger small" ErrorMessage="El código es obligatorio." Display="Dynamic" />
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Tipo de descuento</label>
                            <asp:DropDownList ID="ddlTipoDescuento" runat="server" CssClass="form-select">
                                <asp:ListItem Value="1">Porcentaje (%)</asp:ListItem>
                                <asp:ListItem Value="2">Monto fijo ($)</asp:ListItem>
                                <asp:ListItem Value="3">Reserva gratis</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Valor del descuento</label>
                            <asp:TextBox ID="txtValorDescuento" runat="server" CssClass="form-control" TextMode="Number" placeholder="10" />
                            <small class="text-muted d-block">Dejalo vacío si el tipo es "Reserva gratis".</small>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Reservas requeridas</label>
                            <asp:TextBox ID="txtReservasRequeridas" runat="server" CssClass="form-control" TextMode="Number" placeholder="3" />
                            <asp:RequiredFieldValidator ID="rfvReservas" runat="server"
                                ControlToValidate="txtReservasRequeridas" ValidationGroup="NuevoCupon"
                                CssClass="text-danger small" ErrorMessage="Campo obligatorio." Display="Dynamic" />
                        </div>

                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Válido hasta</label>
                            <asp:TextBox ID="txtValidoHasta" runat="server" CssClass="form-control" TextMode="Date" />
                        </div>

                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Límite de usos</label>
                            <asp:TextBox ID="txtLimiteUsos" runat="server" CssClass="form-control" TextMode="Number" placeholder="50" />
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Cliente (dueño del cupón)</label>
                            <asp:DropDownList ID="ddlUsuario" runat="server" CssClass="form-select" />
                            <asp:RequiredFieldValidator ID="rfvUsuario" runat="server"
                                ControlToValidate="ddlUsuario" InitialValue="0" ValidationGroup="NuevoCupon"
                                CssClass="text-danger small" ErrorMessage="Seleccioná un cliente." Display="Dynamic" />
                        </div>

                        <div class="col-12">
                            <label class="form-label fw-semibold">Descripción</label>
                            <asp:TextBox ID="txtDescripcion" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2"
                                placeholder="Ej: 10% off para clientes con 3+ reservas" MaxLength="300" />
                        </div>

                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <asp:Button ID="btnGuardarCupon" runat="server" Text="Guardar cupón"
                        CssClass="btn btn-success" OnClick="btnGuardarCupon_Click" ValidationGroup="NuevoCupon" />
                </div>
            </div>
        </div>
    </div>

    <script>
        function copiarCodigo(btn, codigo) {
            navigator.clipboard.writeText(codigo).then(function () {
                btn.textContent = 'Copiado';
                setTimeout(function () { btn.textContent = 'Copiar'; }, 1500);
            });
        }

        function setVal(id, v) {
            var el = document.getElementById(id);
            if (el) el.value = v;
        }

        function ocultarError() {
            var err = document.getElementById('<%= lblError.ClientID %>');
            if (err) err.style.display = 'none';
        }

        // Alta: limpia el formulario y deja el hidden vacío
        function nuevoCupon() {
            setVal('<%= hfIdCupon.ClientID %>', '');
            setVal('<%= txtCodigo.ClientID %>', '');
            setVal('<%= ddlTipoDescuento.ClientID %>', '1');
            setVal('<%= txtValorDescuento.ClientID %>', '');
            setVal('<%= txtReservasRequeridas.ClientID %>', '');
            setVal('<%= txtValidoHasta.ClientID %>', '');
            setVal('<%= txtLimiteUsos.ClientID %>', '');
            setVal('<%= txtDescripcion.ClientID %>', '');
            setVal('<%= ddlUsuario.ClientID %>', '0');
            ocultarError();
            document.getElementById('modalNuevoCuponLabel').textContent = 'Nuevo cupón';
        }

    </script>

</asp:Content>
