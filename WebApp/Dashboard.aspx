<%@ Page Title="Panel" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="WebApp.Dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Panel ID="pnlStaff" runat="server" Visible="false">
        <div class="d-flex align-items-center mb-4">
            <div>
                <h2 class="mb-0">Panel</h2>
                <small class="text-muted">
                    <asp:Label ID="lblFecha" runat="server" />
                </small>
            </div>
        </div>


    <%-- Tarjetas KPI --%>
    <div class="row row-cols-1 row-cols-sm-2 row-cols-xl-4 g-3 mb-4">
        <div class="col">
            <div class="kpi card-hover">
                <div class="kpi-top">
                    <div class="kpi-ico">📅</div>
                </div>
                <div class="kpi-value"><asp:Label ID="lblTurnosHoy" runat="server" /></div>
                <div class="kpi-label">Turnos de hoy</div>
            </div>
        </div>
        <div class="col">
            <div class="kpi card-hover">
                <div class="kpi-top">
                    <div class="kpi-ico">🏟️</div>
                </div>
                <div class="kpi-value"><asp:Label ID="lblCanchasActivas" runat="server" /></div>
                <div class="kpi-label">Canchas activas</div>
            </div>
        </div>
        <div class="col">
            <div class="kpi card-hover">
                <div class="kpi-top">
                    <div class="kpi-ico">🎟️</div>
                </div>
                <div class="kpi-value"><asp:Label ID="lblCuponesVigentes" runat="server" /></div>
                <div class="kpi-label">Cupones vigentes</div>
            </div>
        </div>
        <div class="col">
            <div class="kpi card-hover">
                <div class="kpi-top">
                    <div class="kpi-ico">💰</div>
                </div>
                <div class="kpi-value"><asp:Label ID="lblIngresosHoy" runat="server" /></div>
                <div class="kpi-label">Ingresos del día</div>
            </div>
        </div>
    </div>

    <div class="row g-3">

        <%-- Últimas reservas --%>
        <div class="col-lg-8">
            <div class="card-r h-100">
                <div class="card-head">
                    <h6>Últimas reservas</h6>
                    <asp:HyperLink runat="server" NavigateUrl="~/Reservas.aspx"
                        CssClass="btn-r btn-ghost-r btn-sm-r ms-auto">Ver todas</asp:HyperLink>
                </div>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead>
                            <tr class="text-faint" style="font-size:.8rem;">
                                <th class="ps-3 fw-600">Cliente</th>
                                <th>Cancha</th>
                                <th>Horario</th>
                                <th class="text-end pe-3">Estado</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptReservas" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td class="ps-3 fw-semibold"><%# Eval("Cliente") %></td>
                                        <td>
                                            <span class="me-1"><%# GetDeporteEmoji(Eval("Deporte")) %></span>
                                            <%# Eval("Cancha") %>
                                        </td>
                                        <td class="text-soft"><%# Eval("Horario") %></td>
                                        <td class="text-end pe-3">
                                            <span class='<%# GetEstadoBadge(Eval("Estado")) %>'>
                                                <%# Eval("Estado") %>
                                            </span>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    
        <%-- Accesos rápidos --%>
        <div class="col-lg-4">
            <div class="card-r card-r-pad h-100">
                <h6 class="mb-3">Accesos rápidos</h6>
                <div class="d-flex flex-column gap-2">
                    <asp:HyperLink runat="server" NavigateUrl="~/Reservas.aspx"
                        CssClass="btn-r btn-ghost-r">
                        <span>➕</span> Nueva reserva
                    </asp:HyperLink>
                    <asp:HyperLink runat="server" NavigateUrl="~/Canchas.aspx"
                        CssClass="btn-r btn-ghost-r">
                        <span>🏟️</span> Gestionar canchas
                    </asp:HyperLink>
                    <asp:HyperLink runat="server" NavigateUrl="~/Cupones.aspx"
                        CssClass="btn-r btn-ghost-r">
                        <span>🎟️</span> Cupones
                    </asp:HyperLink>
                    <asp:HyperLink runat="server" NavigateUrl="~/Calendario.aspx"
                        CssClass="btn-r btn-ghost-r">
                        <span>🗓️</span> Calendario
                    </asp:HyperLink>
                </div>
            </div>
        </div>
    
    </div>
    
       
       
        
    <%-- Mapa de calor: ocupación por día y turno --%>
    <div class="card-r mt-4">
        <div class="card-head">
            <h6>Ocupación por día y turno</h6>
            <small class="text-faint ms-auto">Reservas efectivas ya ocurridas</small>
        </div>
        <div class="card-r-pad">
            <p class="text-soft mb-3" style="font-size:.85rem;">
                <strong>Cantidad de reservas efectivas</strong> por día y turno (cuanto más oscuro, más concurrido). Debajo, el <strong>porcentaje de ocupación</strong> del turno.
            </p>
            <asp:Literal ID="litHeatmap" runat="server" />
            <div class="heat-legend">
                <span class="text-faint">Menos gente</span>
                <span class="heat-swatch heat-1"></span>
                <span class="heat-swatch heat-2"></span>
                <span class="heat-swatch heat-3"></span>
                <span class="heat-swatch heat-4"></span>
                <span class="heat-swatch heat-5"></span>
                <span class="text-faint">Más gente</span>
            </div>
        </div>
    </div>

    </asp:Panel>

    <asp:Panel ID="pnlCliente" runat="server" Visible="false">
        <div class="p-4 rounded-3 text-white mb-4" style="background:#0d9488">
            <h2 class="mb-1">
                <asp:Label ID="lblBienvenida" runat="server" />
            </h2>
            <p class="mb-3">Reservá tu próxima cancha en segundos.</p>
            <a href="CanchasCliente.aspx" class="btn btn-light fw-semibold">⚽ Reservar ahora</a>
        </div>
        <a href="CuponesCliente.aspx" class="btn btn-outline-success">Ver mis cupones</a>
    </asp:Panel>
</asp:Content>
