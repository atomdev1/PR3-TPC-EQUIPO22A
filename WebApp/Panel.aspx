<%@ Page Title="Panel" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Panel.aspx.cs" Inherits="WebApp.Panel" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .kpi-card {
            border: 1px solid #e9ecef;
            border-radius: 12px;
            background: #fff;
            box-shadow: 0 1px 4px rgba(0,0,0,0.06);
            transition: transform 0.18s ease, box-shadow 0.18s ease;
        }
        .kpi-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 20px rgba(0,0,0,0.10);
        }
        .kpi-icon {
            width: 52px;
            height: 52px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.6rem;
            background: #f8f9fa;
            flex-shrink: 0;
        }
        .kpi-valor {
            font-size: 1.7rem;
            font-weight: 700;
            line-height: 1;
        }
        .kpi-label {
            font-size: 0.85rem;
            color: #9ca3af;
        }
        .panel-card {
            border: 1px solid #e9ecef;
            border-radius: 12px;
            background: #fff;
            box-shadow: 0 1px 4px rgba(0,0,0,0.06);
        }
        .acceso-rapido {
            border: 1px solid #e9ecef;
            border-radius: 10px;
            text-decoration: none;
            color: #374151;
            transition: background 0.15s ease, border-color 0.15s ease;
        }
        .acceso-rapido:hover {
            background: #f8f9fa;
            border-color: #ced4da;
            color: #111827;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="d-flex align-items-center mb-4">
        <div>
            <h2 class="mb-0">Panel</h2>
            <small class="text-muted">
                <asp:Label ID="lblFecha" runat="server" />
            </small>
        </div>
    </div>

    <%-- Tarjetas KPI --%>
    <div class="row row-cols-1 row-cols-sm-2 row-cols-xl-4 g-4 mb-4">
        <div class="col">
            <div class="card kpi-card h-100">
                <div class="card-body d-flex align-items-center gap-3">
                    <div class="kpi-icon" style="background:#e7f5ee;">📅</div>
                    <div>
                        <asp:Label ID="lblTurnosHoy" runat="server" CssClass="kpi-valor d-block" />
                        <span class="kpi-label">Turnos de hoy</span>
                    </div>
                </div>
            </div>
        </div>
        <div class="col">
            <div class="card kpi-card h-100">
                <div class="card-body d-flex align-items-center gap-3">
                    <div class="kpi-icon" style="background:#e7f0fb;">🏟️</div>
                    <div>
                        <asp:Label ID="lblCanchasActivas" runat="server" CssClass="kpi-valor d-block" />
                        <span class="kpi-label">Canchas activas</span>
                    </div>
                </div>
            </div>
        </div>
        <div class="col">
            <div class="card kpi-card h-100">
                <div class="card-body d-flex align-items-center gap-3">
                    <div class="kpi-icon" style="background:#fbf3e0;">🎟️</div>
                    <div>
                        <asp:Label ID="lblCuponesVigentes" runat="server" CssClass="kpi-valor d-block" />
                        <span class="kpi-label">Cupones vigentes</span>
                    </div>
                </div>
            </div>
        </div>
        <div class="col">
            <div class="card kpi-card h-100">
                <div class="card-body d-flex align-items-center gap-3">
                    <div class="kpi-icon" style="background:#ede7fb;">💰</div>
                    <div>
                        <asp:Label ID="lblIngresosHoy" runat="server" CssClass="kpi-valor d-block" />
                        <span class="kpi-label">Ingresos del día</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4">

        <%-- Últimas reservas --%>
        <div class="col-lg-8">
            <div class="card panel-card h-100">
                <div class="card-header bg-white border-bottom d-flex align-items-center py-3">
                    <h6 class="mb-0 fw-semibold">Últimas reservas</h6>
                    <asp:HyperLink runat="server" NavigateUrl="~/Reservas.aspx"
                        CssClass="btn btn-sm btn-light ms-auto">Ver todas</asp:HyperLink>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th class="ps-3">Cliente</th>
                                    <th>Cancha</th>
                                    <th>Horario</th>
                                    <th class="text-end pe-3">Estado</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptReservas" runat="server">
                                    <ItemTemplate>
                                        <tr>
                                            <td class="ps-3">
                                                <span class="fw-semibold"><%# Eval("Cliente") %></span>
                                            </td>
                                            <td>
                                                <span class="me-1"><%# GetDeporteEmoji(Eval("Deporte")) %></span>
                                                <%# Eval("Cancha") %>
                                            </td>
                                            <td class="text-muted"><%# Eval("Horario") %></td>
                                            <td class="text-end pe-3">
                                                <asp:Label runat="server"
                                                    CssClass='<%# GetEstadoBadge(Eval("Estado")) %>'
                                                    Text='<%# Eval("Estado") %>' />
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <%-- Accesos rápidos --%>
        <div class="col-lg-4">
            <div class="card panel-card h-100">
                <div class="card-header bg-white border-bottom py-3">
                    <h6 class="mb-0 fw-semibold">Accesos rápidos</h6>
                </div>
                <div class="card-body d-flex flex-column gap-2">
                    <asp:HyperLink runat="server" NavigateUrl="~/Reservas.aspx"
                        CssClass="acceso-rapido d-flex align-items-center gap-3 p-3">
                        <span class="kpi-icon" style="background:#e7f5ee;font-size:1.3rem;">➕</span>
                        <span>
                            <span class="d-block fw-semibold">Nueva reserva</span>
                            <span class="kpi-label">Cargá un turno</span>
                        </span>
                    </asp:HyperLink>
                    <asp:HyperLink runat="server" NavigateUrl="~/Canchas.aspx"
                        CssClass="acceso-rapido d-flex align-items-center gap-3 p-3">
                        <span class="kpi-icon" style="background:#e7f0fb;font-size:1.3rem;">🏟️</span>
                        <span>
                            <span class="d-block fw-semibold">Gestionar canchas</span>
                            <span class="kpi-label">Altas y bajas</span>
                        </span>
                    </asp:HyperLink>
                    <asp:HyperLink runat="server" NavigateUrl="~/Cupones.aspx"
                        CssClass="acceso-rapido d-flex align-items-center gap-3 p-3">
                        <span class="kpi-icon" style="background:#fbf3e0;font-size:1.3rem;">🎟️</span>
                        <span>
                            <span class="d-block fw-semibold">Cupones</span>
                            <span class="kpi-label">Descuentos vigentes</span>
                        </span>
                    </asp:HyperLink>
                    <asp:HyperLink runat="server" NavigateUrl="~/Calendario.aspx"
                        CssClass="acceso-rapido d-flex align-items-center gap-3 p-3">
                        <span class="kpi-icon" style="background:#ede7fb;font-size:1.3rem;">🗓️</span>
                        <span>
                            <span class="d-block fw-semibold">Calendario</span>
                            <span class="kpi-label">Disponibilidad semanal</span>
                        </span>
                    </asp:HyperLink>
                </div>
            </div>
        </div>

    </div>

</asp:Content>
