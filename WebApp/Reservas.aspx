<%@ Page Title="Reservas" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="false" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Encabezado --%>
    <div class="d-flex align-items-center mb-4">
        <div>
            <h2 class="mb-0">Reservas</h2>
            <small class="text-muted">8 reservas</small>
        </div>
        <button type="button" class="btn btn-success ms-auto"
            data-bs-toggle="modal" data-bs-target="#modalNuevaReserva">
            + Nueva reserva
        </button>
    </div>

    <%-- Filtros --%>
    <div class="card app-card mb-4 p-3">
        <div class="row g-2 align-items-end">
            <div class="col-md-3">
                <label class="form-label small fw-semibold mb-1">Estado</label>
                <select class="form-select form-select-sm">
                    <option value="0">Todos los estados</option>
                    <option value="1">Nueva</option>
                    <option value="2">Reprogramada</option>
                    <option value="3">Cancelada</option>
                    <option value="4">No Asistió</option>
                    <option value="5">Finalizada</option>
                </select>
            </div>
            <div class="col-md-3">
                <label class="form-label small fw-semibold mb-1">Cancha</label>
                <select class="form-select form-select-sm">
                    <option value="0">Todas las canchas</option>
                    <option value="1">La Bombonera</option>
                    <option value="2">El Monumental</option>
                </select>
            </div>
            <div class="col-md-3">
                <label class="form-label small fw-semibold mb-1">Fecha</label>
                <input type="date" class="form-control form-control-sm" />
            </div>
            <div class="col-md-3">
                <button type="button" class="btn btn-sm btn-outline-secondary w-100">Limpiar filtros</button>
            </div>
        </div>
    </div>

    <%-- Tabla de reservas --%>
    <div class="card app-card">
        <div class="card-header bg-white border-bottom d-flex align-items-center py-3">
            <asp:Label ID="lblTotal" runat="server" CssClass="fw-semibold mb-0" />
        </div>
        <div class="table-responsive">
            <table class="table table-hover mb-0 align-middle">
                <thead class="table-light">
                    <tr>
                        <th class="ps-3">#</th>
                        <th>Cliente</th>
                        <th>Cancha</th>
                        <th>Fecha</th>
                        <th>Horario</th>
                        <th>Estado</th>
                        <th>Pago</th>
                        <th class="text-end pe-3">Precio</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptReservas" runat="server">
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
                                        <%# Eval("EstadoPago") %>
                                    </span>
                                </td>
                                <td class="text-end pe-3 fw-semibold small">
                                    <%# string.Format("{0:C0}", Eval("PrecioTotal")) %>
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
                            <p class="form-control-plaintext">Martín Gómez</p>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-semibold">Cancha</label>
                            <p class="form-control-plaintext">La Bombonera · Fútbol</p>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small fw-semibold">Fecha</label>
                            <p class="form-control-plaintext">10/06/2025</p>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small fw-semibold">Horario</label>
                            <p class="form-control-plaintext">09:00 – 10:00</p>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small fw-semibold">Precio total</label>
                            <p class="form-control-plaintext fw-semibold">$6.000</p>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small fw-semibold">Estado reserva</label>
                            <select class="form-select form-select-sm">
                                <option value="1" selected>Nueva</option>
                                <option value="2">Reprogramada</option>
                                <option value="3">Cancelada</option>
                                <option value="4">No Asistió</option>
                                <option value="5">Finalizada</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small fw-semibold">Estado pago</label>
                            <select class="form-select form-select-sm">
                                <option value="1" selected>Pendiente</option>
                                <option value="2">Señado</option>
                                <option value="3">Pagado</option>
                                <option value="4">Reembolsado</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small fw-semibold">Cupón aplicado</label>
                            <p class="form-control-plaintext">—</p>
                        </div>
                        <div class="col-12">
                            <label class="form-label small fw-semibold">Observaciones</label>
                            <textarea class="form-control form-control-sm" rows="2" placeholder="Sin observaciones"></textarea>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cerrar</button>
                    <button type="button" class="btn btn-success">Guardar cambios</button>
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
