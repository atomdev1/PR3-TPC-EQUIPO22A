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
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <%-- Fila 1 --%>
                    <tr>
                        <td class="ps-3 text-muted small">1</td>
                        <td><span class="fw-semibold">Martín Gómez</span></td>
                        <td>
                            <span>La Bombonera</span><br />
                            <span class="cancha-meta">⚽ Fútbol</span>
                        </td>
                        <td class="small">10/06/2025</td>
                        <td class="small">09:00 – 10:00</td>
                        <td><span class="badge fw-normal text-primary bg-primary-subtle">Nueva</span></td>
                        <td><span class="badge fw-normal text-warning bg-warning-subtle">Pendiente</span></td>
                        <td class="text-end pe-3 fw-semibold small">$6.000</td>
                        <td class="pe-3">
                            <div class="d-flex gap-1 justify-content-end">
                                <button type="button" class="btn btn-sm btn-light btn-accion"
                                    data-bs-toggle="modal" data-bs-target="#modalDetalleReserva">Ver</button>
                                <button type="button" class="btn btn-sm btn-outline-danger btn-accion"
                                    onclick="return confirm('¿Cancelar esta reserva?')">Cancelar</button>
                            </div>
                        </td>
                    </tr>
                    <%-- Fila 2 --%>
                    <tr>
                        <td class="ps-3 text-muted small">2</td>
                        <td><span class="fw-semibold">Laura Fernández</span></td>
                        <td>
                            <span>El Monumental</span><br />
                            <span class="cancha-meta">⚽ Fútbol</span>
                        </td>
                        <td class="small">11/06/2025</td>
                        <td class="small">14:00 – 15:00</td>
                        <td><span class="badge fw-normal text-info bg-info-subtle">Reprogramada</span></td>
                        <td><span class="badge fw-normal text-info bg-info-subtle">Señado</span></td>
                        <td class="text-end pe-3 fw-semibold small">$4.500</td>
                        <td class="pe-3">
                            <div class="d-flex gap-1 justify-content-end">
                                <button type="button" class="btn btn-sm btn-light btn-accion"
                                    data-bs-toggle="modal" data-bs-target="#modalDetalleReserva">Ver</button>
                                <button type="button" class="btn btn-sm btn-outline-danger btn-accion"
                                    onclick="return confirm('¿Cancelar esta reserva?')">Cancelar</button>
                            </div>
                        </td>
                    </tr>
                    <%-- Fila 3 --%>
                    <tr>
                        <td class="ps-3 text-muted small">3</td>
                        <td><span class="fw-semibold">Carlos Rodríguez</span></td>
                        <td>
                            <span>Cancha Azul</span><br />
                            <span class="cancha-meta">🏀 Básquet</span>
                        </td>
                        <td class="small">12/06/2025</td>
                        <td class="small">18:00 – 19:00</td>
                        <td><span class="badge fw-normal text-danger bg-danger-subtle">Cancelada</span></td>
                        <td><span class="badge fw-normal text-secondary bg-secondary-subtle">Reembolsado</span></td>
                        <td class="text-end pe-3 fw-semibold small">$5.000</td>
                        <td class="pe-3">
                            <div class="d-flex gap-1 justify-content-end">
                                <button type="button" class="btn btn-sm btn-light btn-accion"
                                    data-bs-toggle="modal" data-bs-target="#modalDetalleReserva">Ver</button>
                            </div>
                        </td>
                    </tr>
                    <%-- Fila 4 --%>
                    <tr>
                        <td class="ps-3 text-muted small">4</td>
                        <td><span class="fw-semibold">Ana Pérez</span></td>
                        <td>
                            <span>La Bombonera</span><br />
                            <span class="cancha-meta">⚽ Fútbol</span>
                        </td>
                        <td class="small">13/06/2025</td>
                        <td class="small">20:00 – 21:00</td>
                        <td><span class="badge fw-normal text-success bg-success-subtle">Finalizada</span></td>
                        <td><span class="badge fw-normal text-success bg-success-subtle">Pagado</span></td>
                        <td class="text-end pe-3 fw-semibold small">$6.000</td>
                        <td class="pe-3">
                            <div class="d-flex gap-1 justify-content-end">
                                <button type="button" class="btn btn-sm btn-light btn-accion"
                                    data-bs-toggle="modal" data-bs-target="#modalDetalleReserva">Ver</button>
                            </div>
                        </td>
                    </tr>
                    <%-- Fila 5 --%>
                    <tr>
                        <td class="ps-3 text-muted small">5</td>
                        <td><span class="fw-semibold">Diego Torres</span></td>
                        <td>
                            <span>El Monumental</span><br />
                            <span class="cancha-meta">🏓 Pádel</span>
                        </td>
                        <td class="small">14/06/2025</td>
                        <td class="small">11:00 – 12:00</td>
                        <td><span class="badge fw-normal text-primary bg-primary-subtle">Nueva</span></td>
                        <td><span class="badge fw-normal text-success bg-success-subtle">Pagado</span></td>
                        <td class="text-end pe-3 fw-semibold small">$3.800</td>
                        <td class="pe-3">
                            <div class="d-flex gap-1 justify-content-end">
                                <button type="button" class="btn btn-sm btn-light btn-accion"
                                    data-bs-toggle="modal" data-bs-target="#modalDetalleReserva">Ver</button>
                                <button type="button" class="btn btn-sm btn-outline-danger btn-accion"
                                    onclick="return confirm('¿Cancelar esta reserva?')">Cancelar</button>
                            </div>
                        </td>
                    </tr>
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
