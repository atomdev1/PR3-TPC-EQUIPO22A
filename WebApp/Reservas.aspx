<%@ Page Title="Reservas" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Reservas.aspx.cs" Inherits="WebApp.Reservas" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Encabezado --%>
    <div class="d-flex align-items-center mb-4">
        <div>
            <h2 class="mb-0">Reservas</h2>
            <small class="text-muted">Gestión de reservas del complejo</small>
        </div>
        <%-- El cliente abre el mismo modal para autogestionar su turno, el texto
             cambia segun el rol. El staff lo titula "Nueva reserva". --%>
        <button type="button" class="btn-r btn-primary-r ms-auto"
            data-bs-toggle="modal" data-bs-target="#modalNuevaReserva">
            ➕ <%= EsCliente ? "Reservar turno" : "Nueva reserva" %>
        </button>
    </div>

    <%-- Filtros (controles de servidor) --%>
    <div class="card-r card-r-pad mb-4">
        <div class="row g-2 align-items-end">
            <div class="col-md-3">
                <label class="form-label small fw-semibold mb-1">Estado</label>
                <asp:DropDownList ID="ddlFiltroEstado" runat="server" CssClass="form-select form-select-sm">
                    <asp:ListItem Value="0">Todos los estados</asp:ListItem>
                    <asp:ListItem Value="1">Nueva</asp:ListItem>
                    <asp:ListItem Value="2">Reprogramada</asp:ListItem>
                    <asp:ListItem Value="3">Cancelada</asp:ListItem>
                    <asp:ListItem Value="4">No Asistió</asp:ListItem>
                    <asp:ListItem Value="5">Finalizada</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-md-3">
                <label class="form-label small fw-semibold mb-1">Cancha</label>
                <asp:DropDownList ID="ddlFiltroCancha" runat="server" CssClass="form-select form-select-sm" />
            </div>
            <div class="col-md-3">
                <label class="form-label small fw-semibold mb-1">Fecha</label>
                <asp:TextBox ID="txtFiltroFecha" runat="server" CssClass="form-control form-control-sm" TextMode="Date" />
            </div>
            <div class="col-md-3 d-flex gap-2">
                <asp:Button ID="btnFiltrar" runat="server" Text="Filtrar" CssClass="btn-r btn-sm-r btn-primary-r w-100"
                    OnClick="btnFiltrar_Click" CausesValidation="false" />
                <asp:Button ID="btnLimpiar" runat="server" Text="Limpiar" CssClass="btn-r btn-sm-r btn-ghost-r w-100"
                    OnClick="btnLimpiar_Click" CausesValidation="false" />
            </div>
        </div>
    </div>

    <%-- Tabla de reservas --%>
    <div class="card-r">
        <div class="card-head">
            <asp:Label ID="lblTotal" runat="server" CssClass="fw-semibold" />
            <asp:Label ID="lblErrorFinalizar" runat="server"
    CssClass="alert alert-danger d-block mt-3" Visible="false" />
        </div>
        <div class="table-responsive">
            <table class="table table-hover mb-0 align-middle">
                <thead class="table-light">
                    <tr>
                        <th class="ps-3" style="width:50px">#</th>
                        <th>Cliente</th>
                        <th>Cancha</th>
                        <th>Fecha</th>
                        <th>Horario</th>
                        <th>Estado</th>
                        <th>Pago</th>
                        <th class="text-end pe-3">Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptReservas" runat="server" OnItemCommand="rptReservas_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td class="ps-3 text-muted small"><%# Eval("IdReserva") %></td>
                                <td><span class="fw-semibold"><%# Eval("Cliente.Nombre") %> <%# Eval("Cliente.Apellido") %></span></td>
                                <td>
                                    <span><%# Eval("Cancha.NombreFantasia") %></span><br />
                                    <span class="text-muted small"><%# Eval("Cancha.Deporte.Nombre") %></span>
                                </td>
                                <td class="small"><%# ((DateTime)Eval("Fecha")).ToString("dd/MM/yyyy") %></td>
                                <td class="small">
                                    <%# ((TimeSpan)Eval("HoraInicio")).ToString(@"hh\:mm") %>
                                    –
                                    <%# ((TimeSpan)Eval("HoraFin")).ToString(@"hh\:mm") %>
                                </td>
                                <td>
                                    <span class='<%# GetBadgeEstado(Eval("Estado")) %>'>
                                        <%# Eval("Estado") %>
                                    </span>
                                </td>
                                <td style="white-space:nowrap">
                                    <span class='<%# GetBadgePago(Eval("EstadoPago")) %>'>
                                        <%# GetTextoPago(Eval("EstadoPago")) %>
                                    </span>
                                    <asp:LinkButton runat="server"
                                        CommandName="VerPagos"
                                        CommandArgument='<%# Eval("IdReserva") %>'
                                        CssClass="d-block btn btn-link btn-sm p-0 mt-1 small text-decoration-none">
                                        🧾 Detalle de pago
                                    </asp:LinkButton>
                                </td>

                                <td class="text-end pe-3">
                                    <% if (!EsCliente) { %>
                                    <div class="dropdown">
                                        <button type="button" class="btn btn-sm btn-outline-secondary dropdown-toggle"
                                            data-bs-toggle="dropdown" aria-expanded="false">
                                            <%--Acciones--%>
                                        </button>
                                        <ul class="dropdown-menu dropdown-menu-end">
                                            <li>
                                                <asp:LinkButton runat="server"
                                                    CommandName="Ver"
                                                    CommandArgument='<%# Eval("IdReserva") %>'
                                                    CssClass="dropdown-item">
                                                    Ver detalle
                                                </asp:LinkButton>
                                            </li>
                                            <li>
                                                <asp:LinkButton runat="server"
                                                    CommandName="RegistrarPago"
                                                    CommandArgument='<%# Eval("IdReserva") %>'
                                                    CssClass="dropdown-item">
                                                    Registrar pago
                                                </asp:LinkButton>
                                            </li>
                                            <li>
                                                <asp:LinkButton runat="server"
                                                    CommandName="Canjear"
                                                    CommandArgument='<%# Eval("IdReserva") %>'
                                                    CssClass="dropdown-item"
                                                    Visible='<%# (int)Eval("EstadoPago") != 3 %>'>
                                                    Canjear cupón
                                                </asp:LinkButton>
                                            </li>
                                            <li><hr class="dropdown-divider" /></li>
                                            <li>
                                                <asp:LinkButton runat="server"
                                                    CommandName="Reprogramar"
                                                    CommandArgument='<%# Eval("IdReserva") %>'
                                                    CssClass="dropdown-item"
                                                    Visible='<%# (int)Eval("Estado") == 1 || (int)Eval("Estado") == 2 %>'>
                                                    Reprogramar
                                                </asp:LinkButton>
                                            </li>
                                            <li>
                                                <asp:LinkButton runat="server"
                                                    CommandName="Finalizar"
                                                    CommandArgument='<%# Eval("IdReserva") %>'
                                                    CssClass="dropdown-item"
                                                    Visible='<%# (int)Eval("Estado") == 1 || (int)Eval("Estado") == 2 %>'>
                                                    Finalizar
                                                </asp:LinkButton>
                                            </li>
                                            <li>
                                                <asp:LinkButton runat="server"
                                                    CommandName="Cancelar"
                                                    CommandArgument='<%# Eval("IdReserva") %>'
                                                    CssClass="dropdown-item text-danger"
                                                    Visible='<%# (int)Eval("Estado") != 3 && (int)Eval("Estado") != 5 %>'>
                                                    Cancelar reserva
                                                </asp:LinkButton>
                                            </li>
                                        </ul>
                                    </div>
                                    <% } else { %>
                                    <asp:LinkButton runat="server"
                                        CommandName="PagarOnline"
                                        CommandArgument='<%# Eval("IdReserva") %>'
                                        CssClass="btn btn-sm btn-primary-r me-1"
                                        Visible='<%# (decimal)Eval("SaldoPendiente") > 0 && (int)Eval("Estado") != 3 %>'>
                                        💳 Pagar online
                                    </asp:LinkButton>
                                    <asp:LinkButton runat="server"
                                        CommandName="Canjear"
                                        CommandArgument='<%# Eval("IdReserva") %>'
                                        CssClass="btn btn-sm btn-outline-primary"
                                        Visible='<%# (int)Eval("EstadoPago") != 3 %>'>
                                        Canjear cupón
                                    </asp:LinkButton>
                                    <% } %>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </div>

    <%-- ===================== MODAL DETALLE ===================== --%>
    <div class="modal fade" id="modalDetalleReserva" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Detalle de reserva</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label small fw-semibold">Cliente</label>
                            <p class="form-control-plaintext"><asp:Label ID="lblDetCliente" runat="server" /></p>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-semibold">Cancha</label>
                            <p class="form-control-plaintext"><asp:Label ID="lblDetCancha" runat="server" /></p>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small fw-semibold">Fecha</label>
                            <p class="form-control-plaintext"><asp:Label ID="lblDetFecha" runat="server" /></p>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small fw-semibold">Horario</label>
                            <p class="form-control-plaintext"><asp:Label ID="lblDetHorario" runat="server" /></p>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small fw-semibold">Precio total</label>
                            <p class="form-control-plaintext fw-semibold"><asp:Label ID="lblDetPrecio" runat="server" /></p>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small fw-semibold">Estado reserva</label>
                            <p class="form-control-plaintext"><asp:Label ID="lblDetEstado" runat="server" /></p>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small fw-semibold">Estado pago</label>
                            <p class="form-control-plaintext"><asp:Label ID="lblDetPago" runat="server" /></p>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small fw-semibold">Pagado</label>
                            <p class="form-control-plaintext fw-semibold text-success"><asp:Label ID="lblDetPagado" runat="server" /></p>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small fw-semibold">Saldo pendiente</label>
                            <p class="form-control-plaintext fw-semibold"><asp:Label ID="lblDetSaldo" runat="server" /></p>
                        </div>
                        <div class="col-12">
                            <label class="form-label small fw-semibold">Observaciones</label>
                            <p class="form-control-plaintext"><asp:Label ID="lblDetObs" runat="server" /></p>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cerrar</button>
                </div>
            </div>
        </div>
    </div>

    <%-- ===================== MODAL DETALLE DE PAGO ===================== --%>
    <%-- Muestra el desglose real: cada pago (seña / saldo) con su fecha y forma. --%>
    <div class="modal fade" id="modalDetallePago" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Detalle de pago</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                </div>
                <div class="modal-body">
                    <asp:Label ID="lblPagosReserva" runat="server" CssClass="fw-semibold d-block mb-2" />
                    <div class="d-flex justify-content-between small text-muted mb-3">
                        <span>Precio total: <asp:Label ID="lblPagosPrecio" runat="server" /></span>
                        <span>Pagado: <asp:Label ID="lblPagosPagado" runat="server" /></span>
                        <span>Saldo: <asp:Label ID="lblPagosSaldo" runat="server" CssClass="fw-semibold" /></span>
                    </div>

                    <div class="table-responsive">
                        <table class="table table-sm align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Fecha</th>
                                    <th>Forma de pago</th>
                                    <th class="text-end">Monto</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptPagos" runat="server">
                                    <ItemTemplate>
                                        <tr>
                                            <td class="small"><%# ((DateTime)Eval("FechaHora")).ToString("dd/MM/yyyy HH:mm") %></td>
                                            <td class="small"><%# GetTextoFormaPago(Eval("FormaDePago")) %></td>
                                            <td class="text-end fw-semibold small"><%# string.Format("{0:C0}", Eval("Monto")) %></td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>
                    <asp:Label ID="lblPagosVacio" runat="server" CssClass="text-muted small" Visible="false"
                        Text="Todavía no se registraron pagos para esta reserva." />
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cerrar</button>
                </div>
            </div>
        </div>
    </div>

    <%-- MODAL REGISTRAR PAGO --%>
    <%-- El INSERT en Pagos dispara TR_SincronizarEstadoPago, que recalcula el
         estado de pago de la reserva (Señado / Pagado) de forma automática. --%>
    <div class="modal fade" id="modalRegistrarPago" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Registrar pago</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hfIdReservaPago" runat="server" />
                    <asp:Label ID="lblErrorPago" runat="server" CssClass="alert alert-danger d-block" Visible="false" />

                    <div class="mb-3">
                        <asp:Label ID="lblPagoReserva" runat="server" CssClass="fw-semibold d-block" />
                        <div class="d-flex justify-content-between small text-muted mt-1">
                            <span>Precio total: <asp:Label ID="lblPagoPrecio" runat="server" /></span>
                            <span>Pagado: <asp:Label ID="lblPagoPagado" runat="server" /></span>
                            <span>Saldo: <asp:Label ID="lblPagoSaldo" runat="server" CssClass="fw-semibold" /></span>
                        </div>
                    </div>

                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Monto ($)</label>
                            <asp:TextBox ID="txtMontoPago" runat="server" CssClass="form-control" TextMode="Number" />
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Forma de pago</label>
                            <asp:DropDownList ID="ddlFormaPago" runat="server" CssClass="form-select">
                                <asp:ListItem Value="1">Efectivo</asp:ListItem>
                                <asp:ListItem Value="2">Transferencia</asp:ListItem>
                                <asp:ListItem Value="3">Tarjeta de débito</asp:ListItem>
                                <asp:ListItem Value="4">Tarjeta de crédito</asp:ListItem>
                                <asp:ListItem Value="5">Mercado Pago</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-r btn-ghost-r" data-bs-dismiss="modal">Cancelar</button>
                    <asp:Button ID="btnConfirmarPago" runat="server" Text="Registrar pago"
                        CssClass="btn-r btn-primary-r" OnClick="btnConfirmarPago_Click" CausesValidation="false" />
                </div>
            </div>
        </div>
    </div>

    <%-- MODAL PAGO ONLINE (CLIENTE) --%>
    <%-- Pago simulado. El método cambia por AutoPostBack dentro del UpdatePanel,
         así el modal no se cierra. El número de tarjeta no se guarda. --%>
    <div class="modal fade" id="modalPagoOnline" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Pagar online</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                </div>
                <div class="modal-body">
                    <asp:UpdatePanel ID="upPagoOnline" runat="server">
                        <ContentTemplate>
                            <asp:HiddenField ID="hfIdReservaOnline" runat="server" />

                            <%-- Formulario del pago. Lo oculto al confirmar. --%>
                            <asp:Panel ID="pnlFormularioOnline" runat="server">
                            <asp:Label ID="lblErrorOnline" runat="server" CssClass="alert alert-danger d-block" Visible="false" />

                            <div class="alert alert-warning small py-2">
                                🔒 Pago simulado · entorno de prueba. No se realiza ningún cobro real.
                            </div>

                            <div class="mb-3">
                                <asp:Label ID="lblOnlineReserva" runat="server" CssClass="fw-semibold d-block" />
                                <div class="d-flex justify-content-between small text-muted mt-1">
                                    <span>Precio total: <asp:Label ID="lblOnlinePrecio" runat="server" /></span>
                                    <span>Pagado: <asp:Label ID="lblOnlinePagado" runat="server" /></span>
                                    <span>Saldo: <asp:Label ID="lblOnlineSaldo" runat="server" CssClass="fw-semibold" /></span>
                                </div>
                            </div>

                            <div class="row g-3 mb-1">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Monto ($)</label>
                                    <asp:TextBox ID="txtMontoOnline" runat="server" CssClass="form-control" TextMode="Number" />
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Método</label>
                                    <asp:DropDownList ID="ddlMetodoOnline" runat="server" CssClass="form-select"
                                        AutoPostBack="true" OnSelectedIndexChanged="ddlMetodoOnline_SelectedIndexChanged">
                                        <asp:ListItem Value="4">Tarjeta de crédito</asp:ListItem>
                                        <asp:ListItem Value="3">Tarjeta de débito</asp:ListItem>
                                        <asp:ListItem Value="5">Mercado Pago</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>

                            <%-- Datos de tarjeta: solo para la simulación, no se persisten. --%>
                            <asp:Panel ID="pnlTarjetaOnline" runat="server" CssClass="mt-2">
                                <div class="row g-3">
                                    <div class="col-12">
                                        <label class="form-label fw-semibold">Titular</label>
                                        <asp:TextBox ID="txtTitular" runat="server" CssClass="form-control"
                                            placeholder="Como figura en la tarjeta" />
                                        <asp:RequiredFieldValidator ID="rfvTitular" runat="server"
                                            ControlToValidate="txtTitular" ValidationGroup="PagoOnline"
                                            CssClass="text-danger small" Display="Dynamic"
                                            ErrorMessage="Ingresá el titular de la tarjeta." />
                                    </div>
                                    <div class="col-12">
                                        <label class="form-label fw-semibold">Número de tarjeta</label>
                                        <asp:TextBox ID="txtNumeroTarjeta" runat="server" CssClass="form-control"
                                            placeholder="Solo números (13 a 19 dígitos)" />
                                        <asp:RequiredFieldValidator ID="rfvNumero" runat="server"
                                            ControlToValidate="txtNumeroTarjeta" ValidationGroup="PagoOnline"
                                            CssClass="text-danger small" Display="Dynamic"
                                            ErrorMessage="Ingresá el número de tarjeta." />
                                        <asp:RegularExpressionValidator ID="revNumero" runat="server"
                                            ControlToValidate="txtNumeroTarjeta" ValidationGroup="PagoOnline"
                                            ValidationExpression="\d{13,19}"
                                            CssClass="text-danger small" Display="Dynamic"
                                            ErrorMessage="El número debe tener entre 13 y 19 dígitos." />
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold">Vencimiento</label>
                                        <asp:TextBox ID="txtVencimiento" runat="server" CssClass="form-control"
                                            placeholder="MM/AA" />
                                        <asp:RequiredFieldValidator ID="rfvVencimiento" runat="server"
                                            ControlToValidate="txtVencimiento" ValidationGroup="PagoOnline"
                                            CssClass="text-danger small" Display="Dynamic"
                                            ErrorMessage="Ingresá el vencimiento." />
                                        <asp:RegularExpressionValidator ID="revVencimiento" runat="server"
                                            ControlToValidate="txtVencimiento" ValidationGroup="PagoOnline"
                                            ValidationExpression="(0[1-9]|1[0-2])/\d{2}"
                                            CssClass="text-danger small" Display="Dynamic"
                                            ErrorMessage="El vencimiento debe tener el formato MM/AA." />
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold">CVV</label>
                                        <asp:TextBox ID="txtCvv" runat="server" CssClass="form-control"
                                            placeholder="123" />
                                        <asp:RequiredFieldValidator ID="rfvCvv" runat="server"
                                            ControlToValidate="txtCvv" ValidationGroup="PagoOnline"
                                            CssClass="text-danger small" Display="Dynamic"
                                            ErrorMessage="Ingresá el CVV." />
                                        <asp:RegularExpressionValidator ID="revCvv" runat="server"
                                            ControlToValidate="txtCvv" ValidationGroup="PagoOnline"
                                            ValidationExpression="\d{3,4}"
                                            CssClass="text-danger small" Display="Dynamic"
                                            ErrorMessage="El CVV debe tener 3 o 4 dígitos." />
                                    </div>
                                </div>
                                <p class="text-muted small mt-2 mb-0">
                                    No guardamos los datos de tu tarjeta: se usan solo para simular el pago.
                                </p>
                            </asp:Panel>

                            <%-- Mercado Pago: arranca oculto, lo muestra el server si se elige el método. --%>
                            <asp:Panel ID="pnlMercadoPagoOnline" runat="server" CssClass="mt-2" Visible="false">
                                <div class="alert alert-info small mb-0">
                                    Al confirmar vas a ser redirigido a <strong>Mercado Pago</strong> (entorno de prueba)
                                    y volvés con el pago acreditado.
                                </div>
                            </asp:Panel>
                            </asp:Panel>

                            <%-- Éxito: lo muestro al confirmar, en lugar del formulario. --%>
                            <asp:Panel ID="pnlExitoOnline" runat="server" Visible="false">
                                <div class="text-center py-4">
                                    <div class="text-success mb-2" style="font-size:2.5rem; line-height:1">✓</div>
                                    <h5 class="text-success mb-3">Pago acreditado</h5>
                                    <asp:Label ID="lblExitoOnline" runat="server" CssClass="d-block text-muted" />
                                </div>
                            </asp:Panel>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-r btn-ghost-r" data-bs-dismiss="modal">Cerrar</button>
                    <asp:Button ID="btnConfirmarPagoOnline" runat="server" Text="Confirmar pago"
                        CssClass="btn-r btn-primary-r" OnClick="btnConfirmarPagoOnline_Click" ValidationGroup="PagoOnline" />
                </div>
            </div>
        </div>
    </div>

    <%-- MODAL CANJEAR CUPÓN --%>
    <%-- El canje lo hace el SP sp_CanjearCupon. Si una regla falla, el mensaje
         del THROW se muestra acá mismo. --%>
    <div class="modal fade" id="modalCanjearCupon" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Canjear cupón</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hfIdReservaCanje" runat="server" />
                    <asp:Label ID="lblErrorCanje" runat="server" CssClass="alert alert-danger d-block" Visible="false" />

                    <div class="mb-3">
                        <asp:Label ID="lblCanjeReserva" runat="server" CssClass="fw-semibold d-block" />
                        <div class="small text-muted mt-1">
                            <span>Precio actual: <asp:Label ID="lblCanjePrecio" runat="server" /></span>
                        </div>
                    </div>

                    <div class="mb-1">
                        <label class="form-label fw-semibold">Código del cupón</label>
                        <asp:TextBox ID="txtCodigoCupon" runat="server" CssClass="form-control"
                            placeholder="Ej: FID-LUC-15" />
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-r btn-ghost-r" data-bs-dismiss="modal">Cancelar</button>
                    <asp:Button ID="btnConfirmarCanje" runat="server" Text="Canjear cupón"
                        CssClass="btn-r btn-primary-r" OnClick="btnConfirmarCanje_Click" CausesValidation="false" />
                </div>
            </div>
        </div>
    </div>

    <%-- MODAL CANCELAR RESERVA --%>
    <div class="modal fade" id="modalCancelarReserva" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Cancelar reserva</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hfIdReservaCancelacion" runat="server" />
                    <asp:Label ID="lblErrorCancelacion" runat="server" CssClass="alert alert-danger d-block" Visible="false" />

                    <p>¿Estás seguro que querés cancelar esta reserva?</p>
                    <div class="mb-2">
                        <asp:Label ID="lblCancelacionReserva" runat="server" CssClass="fw-semibold d-block" />
                        <div class="small text-muted mt-1">
                            <span>Cliente: <asp:Label ID="lblCancelacionCliente" runat="server" /></span><br />
                            <span>Fecha: <asp:Label ID="lblCancelacionFecha" runat="server" /></span><br />
                            <span>Precio: <asp:Label ID="lblCancelacionPrecio" runat="server" /></span>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-r btn-ghost-r" data-bs-dismiss="modal">Volver</button>
                    <asp:Button ID="btnConfirmarCancelacion" runat="server" Text="Sí, cancelar reserva"
                        CssClass="btn-r btn-danger-r" OnClick="btnConfirmarCancelacion_Click" CausesValidation="false" />
                </div>
            </div>
        </div>
    </div>

    <%-- ===================== MODAL REPROGRAMAR ===================== --%>
    <%-- Mueve el turno a otra fecha/horario de la misma cancha. El error vive
         dentro del modal y se resetea al abrir, asi nunca queda colgado. --%>
    <div class="modal fade" id="modalReprogramar" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Reprogramar reserva</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                </div>
                <div class="modal-body">
                    <asp:UpdatePanel ID="upReprogramar" runat="server">
                        <ContentTemplate>
                            <asp:HiddenField ID="hfIdReservaReprogramar" runat="server" />
                            <asp:HiddenField ID="hfIdCanchaReprogramar" runat="server" />
                            <asp:Label ID="lblErrorReprogramar" runat="server" CssClass="alert alert-danger d-block" Visible="false" />

                            <div class="mb-3">
                                <asp:Label ID="lblReprogramarReserva" runat="server" CssClass="fw-semibold d-block" />
                                <div class="small text-muted mt-1">
                                    <span>Cliente: <asp:Label ID="lblReprogramarCliente" runat="server" /></span><br />
                                    <span>Cancha: <asp:Label ID="lblReprogramarCancha" runat="server" /></span><br />
                                    <span>Turno actual: <asp:Label ID="lblReprogramarActual" runat="server" /></span>
                                </div>
                            </div>

                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Nueva fecha</label>
                                    <asp:TextBox ID="txtFechaReprogramar" runat="server" CssClass="form-control" TextMode="Date"
                                        AutoPostBack="true" OnTextChanged="txtFechaReprogramar_TextChanged" />
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Nuevo horario <span class="text-muted fw-normal">(turnos de 1 hora)</span></label>
                                    <asp:DropDownList ID="ddlHorarioReprogramar" runat="server" CssClass="form-select" />
                                    <asp:Label ID="lblSinHorariosReprog" runat="server" CssClass="text-muted small" Visible="false"
                                        Text="No hay turnos disponibles para esa cancha en esa fecha." />
                                </div>
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-r btn-ghost-r" data-bs-dismiss="modal">Volver</button>
                    <asp:Button ID="btnConfirmarReprogramar" runat="server" Text="Reprogramar turno"
                        CssClass="btn-r btn-primary-r" OnClick="btnConfirmarReprogramar_Click" CausesValidation="false" />
                </div>
            </div>
        </div>
    </div>

    <%-- ===================== MODAL NUEVA RESERVA ===================== --%>
    <div class="modal fade" id="modalNuevaReserva" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Nueva reserva</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                </div>
                <div class="modal-body">
                    <asp:UpdatePanel ID="upNuevaReserva" runat="server">
                        <ContentTemplate>
                            <asp:Label ID="lblErrorNueva" runat="server" CssClass="alert alert-danger d-block" Visible="false" />
                            <div class="row g-3">
                                <%-- El combo de cliente solo lo ve el mostrador. Para el cliente
                                     que autogestiona, el cliente es el de la sesion. --%>
                                <asp:Panel ID="pnlClienteNueva" runat="server" CssClass="col-md-6">
                                    <label class="form-label fw-semibold">Cliente</label>
                                    <asp:DropDownList ID="ddlClienteNueva" runat="server" CssClass="form-select" />
                                </asp:Panel>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Cancha</label>
                                    <asp:DropDownList ID="ddlCanchaNueva" runat="server" CssClass="form-select"
                                        AutoPostBack="true" OnSelectedIndexChanged="ddlCanchaNueva_SelectedIndexChanged" />
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Fecha</label>
                                    <asp:TextBox ID="txtFechaNueva" runat="server" CssClass="form-control" TextMode="Date"
                                        AutoPostBack="true" OnTextChanged="txtFechaNueva_TextChanged" />
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Precio total ($)</label>
                                    <asp:TextBox ID="txtPrecioNueva" runat="server" CssClass="form-control" TextMode="Number" />
                                    <asp:Label ID="lblAyudaPrecio" runat="server" CssClass="text-muted small"
                                        Text="Se autocompleta con el precio de la cancha, lo podés ajustar." />
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-semibold">Horario <span class="text-muted fw-normal">(turnos de 1 hora)</span></label>
                                    <%-- Atajo: los primeros turnos libres. Si no le sirve ninguno, elige del combo. --%>
                                    <asp:Panel ID="pnlSugeridos" runat="server" CssClass="d-flex flex-wrap align-items-center gap-2 mb-2" Visible="false">
                                        <span class="text-muted small w-100 mb-0">Turnos sugeridos:</span>
                                        <asp:Repeater ID="rptSugeridos" runat="server" OnItemCommand="rptSugeridos_ItemCommand">
                                            <ItemTemplate>
                                                <asp:LinkButton runat="server" CommandName="ElegirHorario"
                                                    CommandArgument='<%# ((TimeSpan)Container.DataItem).ToString(@"hh\:mm") %>'
                                                    CssClass="btn btn-sm btn-outline-primary">
                                                    <%# FormatoTurno(Container.DataItem) %>
                                                </asp:LinkButton>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </asp:Panel>
                                    <asp:DropDownList ID="ddlHorarioNueva" runat="server" CssClass="form-select" />
                                    <asp:Label ID="lblSinHorarios" runat="server" CssClass="text-muted small" Visible="false"
                                        Text="Elegí una cancha y una fecha para ver los turnos disponibles." />
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-semibold">
                                        Observaciones <span class="text-muted fw-normal">(opcional)</span>
                                    </label>
                                    <asp:TextBox ID="txtObservacionesNueva" runat="server" CssClass="form-control"
                                        TextMode="MultiLine" Rows="2" MaxLength="255" />
                                </div>
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <asp:Button ID="btnGuardarReserva" runat="server" Text="Guardar reserva"
                        CssClass="btn-r btn-primary-r" OnClick="btnGuardarReserva_Click" CausesValidation="false" />
                </div>
            </div>
        </div>
    </div>

</asp:Content>
