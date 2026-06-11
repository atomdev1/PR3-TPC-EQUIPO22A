<%@ Page Title="Mis cupones" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CuponesCliente.aspx.cs" Inherits="WebApp.CuponesCliente" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="d-flex align-items-center mb-4">
        <div>
            <h2 class="mb-0">Mis cupones</h2>
            <small class="text-muted">
                <asp:Label ID="lblTotal" runat="server" />
            </small>
        </div>
    </div>

    <%-- Cómo se obtienen los cupones: explica la mecánica de fidelidad al cliente --%>
    <div class="fidelidad-banner d-flex align-items-center gap-3 mb-4">
        <div class="fidelidad-icon">🎯</div>
        <div>
            <div class="fw-semibold mb-1">¿Cómo consigo cupones?</div>
            <div class="text-muted" style="font-size:0.875rem">
                El complejo premia a sus clientes frecuentes. Cada vez que reservás una cancha
                sumás para tus recompensas: al alcanzar las reservas que pide cada cupón, queda
                disponible para usar. Aprovechalo antes de su vencimiento y dentro del límite de usos.
            </div>
        </div>
    </div>

    <%-- Estado vacío global: el cliente no tiene ningún cupón --%>
    <asp:Panel ID="pnlVacio" runat="server" Visible="false" CssClass="alert alert-info">
        Todavía no tenés cupones. Reservá canchas y empezá a sumar para tus recompensas.
    </asp:Panel>

    <%-- ───────── Disponibles ───────── --%>
    <asp:Panel ID="pnlDisponibles" runat="server">
        <h5 class="fw-semibold mb-3">Disponibles para usar</h5>

        <asp:Panel ID="pnlSinDisponibles" runat="server" Visible="false"
            CssClass="alert alert-light border mb-4">
            No tenés cupones disponibles ahora mismo.
        </asp:Panel>

        <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4 mb-5">
            <asp:Repeater ID="rptDisponibles" runat="server">
                <ItemTemplate>
                    <div class="col">
                        <div class="card h-100 app-card app-card-hover">
                            <div class="card-body d-flex flex-column p-3">

                                <%-- Header: badge descuento + código + estado --%>
                                <div class="d-flex align-items-start gap-3 mb-3">
                                    <asp:Panel runat="server" CssClass="cupon-descuento-badge">
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
                                    CssClass="cupon-valor d-block mb-1"
                                    Text='<%# FormatearValor(Eval("TipoDescuento"), Eval("ValorDescuento")) %>' />

                                <%-- Descripción --%>
                                <asp:Label runat="server" CssClass="cupon-descripcion d-block mb-3"
                                    Text='<%# Eval("Descripcion") %>' />

                                <%-- Metadatos --%>
                                <div class="d-flex flex-column gap-1 mt-auto cupon-divider pt-3 cupon-meta">
                                    <asp:Label runat="server" Text='<%# FormatearMeta("reservas-obtenidas", Eval("ReservasRequeridas")) %>' />
                                    <asp:Label runat="server" Text='<%# FormatearMeta("fecha", Eval("ValidoHasta")) %>' />
                                    <asp:Label runat="server" Text='<%# FormatearMeta("usos", Eval("UsosActuales"), Eval("LimiteUsos")) %>' />
                                </div>

                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>

    <%-- ───────── En camino (objetivos por alcanzar) ───────── --%>
    <asp:Panel ID="pnlObjetivos" runat="server" Visible="false">
        <h5 class="fw-semibold mb-1">En camino</h5>
        <small class="text-muted d-block mb-3">Sumá reservas y desbloqueá estos beneficios. Se activan solos al alcanzarlos.</small>

        <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4 mb-5">
            <asp:Repeater ID="rptObjetivos" runat="server">
                <ItemTemplate>
                    <div class="col">
                        <div class="card h-100 app-card cupon-card-objetivo">
                            <div class="card-body d-flex flex-column p-3">

                                <%-- Header: badge + nombre del beneficio --%>
                                <div class="d-flex align-items-start gap-3 mb-3">
                                    <div class="cupon-descuento-badge objetivo-badge">
                                        <asp:Label runat="server" Text='<%# GetBadgeSymbol(Eval("TipoDescuento")) %>' />
                                    </div>
                                    <div class="flex-grow-1 min-w-0">
                                        <asp:Label runat="server" CssClass="fw-semibold d-block" Text='<%# Eval("Nombre") %>' />
                                        <asp:Label runat="server" CssClass="cupon-tipo-label d-block"
                                            Text='<%# GetTipoNombre(Eval("TipoDescuento")) %>' />
                                    </div>
                                </div>

                                <%-- Valor --%>
                                <asp:Label runat="server" CssClass="cupon-valor d-block mb-1"
                                    Text='<%# FormatearValor(Eval("TipoDescuento"), Eval("ValorDescuento")) %>' />

                                <%-- Descripción --%>
                                <asp:Label runat="server" CssClass="cupon-descripcion d-block mb-3"
                                    Text='<%# Eval("Descripcion") %>' />

                                <%-- Progreso: cuánto le falta al cliente --%>
                                <div class="mt-auto cupon-divider pt-3">
                                    <div class="d-flex justify-content-between cupon-meta mb-1">
                                        <asp:Label runat="server" CssClass="fw-semibold text-dark"
                                            Text='<%# TextoFaltantes(Container.DataItem) %>' />
                                        <asp:Label runat="server" Text='<%# ProgresoFraccion(Container.DataItem) %>' />
                                    </div>
                                    <div class="progress objetivo-progress">
                                        <div class="progress-bar" role="progressbar"
                                            style='<%# "width:" + ProgresoPorcentaje(Container.DataItem) + "%" %>'></div>
                                    </div>
                                </div>

                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>

    <%-- ───────── Historial ───────── --%>
    <asp:Panel ID="pnlHistorial" runat="server" Visible="false">
        <h5 class="fw-semibold mb-1">Historial</h5>
        <small class="text-muted d-block mb-3">Cupones que ya canjeaste, se vencieron o se agotaron.</small>

        <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
            <asp:Repeater ID="rptHistorial" runat="server">
                <ItemTemplate>
                    <div class="col">
                        <div class="card h-100 app-card cupon-card-inactivo">
                            <div class="card-body d-flex flex-column p-3">

                                <div class="d-flex align-items-start gap-3 mb-3">
                                    <asp:Panel runat="server" CssClass="cupon-descuento-badge">
                                        <asp:Label runat="server" Text='<%# GetBadgeSymbol(Eval("TipoDescuento")) %>' />
                                    </asp:Panel>
                                    <div class="flex-grow-1 min-w-0">
                                        <div class="d-flex justify-content-between align-items-start">
                                            <asp:Label runat="server" CssClass="cupon-codigo" Text='<%# Eval("Codigo") %>' />
                                            <asp:Label runat="server"
                                                CssClass='<%# "badge fw-normal flex-shrink-0 " + GetEstadoBadgeClass(Eval("Estado")) %>'
                                                Text='<%# Eval("Estado").ToString() %>' />
                                        </div>
                                        <asp:Label runat="server" CssClass="cupon-tipo-label d-block mt-1"
                                            Text='<%# GetTipoNombre(Eval("TipoDescuento")) %>' />
                                    </div>
                                </div>

                                <asp:Label runat="server"
                                    CssClass="cupon-valor d-block mb-1"
                                    Text='<%# FormatearValor(Eval("TipoDescuento"), Eval("ValorDescuento")) %>' />

                                <asp:Label runat="server" CssClass="cupon-descripcion d-block mb-3"
                                    Text='<%# Eval("Descripcion") %>' />

                                <div class="d-flex flex-column gap-1 mt-auto cupon-divider pt-3 cupon-meta">
                                    <asp:Label runat="server" Text='<%# FormatearMeta("reservas-obtenidas", Eval("ReservasRequeridas")) %>' />
                                    <asp:Label runat="server" Text='<%# FormatearMeta("fecha", Eval("ValidoHasta")) %>' />
                                    <asp:Label runat="server" Text='<%# FormatearMeta("usos", Eval("UsosActuales"), Eval("LimiteUsos")) %>' />
                                </div>

                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>

    <script>
        function copiarCodigo(btn, codigo) {
            navigator.clipboard.writeText(codigo).then(function () {
                btn.textContent = 'Copiado';
                setTimeout(function () { btn.textContent = 'Copiar'; }, 1500);
            });
        }
    </script>

</asp:Content>
