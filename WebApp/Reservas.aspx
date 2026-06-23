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
        <% if (!EsCliente) { %>
        <button type="button" class="btn-r btn-primary-r ms-auto"
            data-bs-toggle="modal" data-bs-target="#modalNuevaReserva">
            ➕ Nueva reserva
        </button>
        <% } %>
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
                        <th class="text-end pe-3">Precio</th>
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
                                <td>
                                    <span class='<%# GetBadgePago(Eval("EstadoPago")) %>'>
                                        <%# GetTextoPago(Eval("EstadoPago")) %>
                                    </span>
                                </td>
                                <td class="text-end pe-3 fw-semibold small" style="white-space:nowrap">
                                    <%# string.Format("{0:C0}", Eval("PrecioTotal")) %>
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

    <%-- ===================== MODAL NUEVA RESERVA ===================== --%>
    <div class="modal fade" id="modalNuevaReserva" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Nueva reserva</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Cliente</label>
                            <select class="form-select">
                                <option value="0">-- Seleccioná un cliente --</option>
                                <option value="1">Fernández, Laura</option>
                                <option value="2">Gómez, Martín</option>
                                <option value="3">Pérez, Ana</option>
                                <option value="4">Rodríguez, Carlos</option>
                                <option value="5">Torres, Diego</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Cancha</label>
                            <select class="form-select">
                                <option value="0">-- Seleccioná una cancha --</option>
                                <option value="1">La Bombonera (Fútbol)</option>
                                <option value="2">El Monumental (Tenis)</option>
                                <option value="3">Cancha Azul (Básquet)</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Fecha</label>
                            <input type="date" class="form-control" />
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Hora inicio</label>
                            <input type="time" class="form-control" />
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Hora fin</label>
                            <input type="time" class="form-control" />
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Estado de pago</label>
                            <select class="form-select">
                                <option value="1">Pendiente</option>
                                <option value="2">Señado</option>
                                <option value="3">Pagado</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Precio total ($)</label>
                            <input type="number" class="form-control" placeholder="6000" />
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold">
                                Observaciones <span class="text-muted fw-normal">(opcional)</span>
                            </label>
                            <textarea class="form-control" rows="2" maxlength="255"></textarea>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button type="button" class="btn btn-success">Guardar reserva</button>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
