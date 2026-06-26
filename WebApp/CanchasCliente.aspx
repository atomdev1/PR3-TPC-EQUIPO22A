<%@ Page Title="Reservar cancha" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CanchasCliente.aspx.cs" Inherits="WebApp.CanchasCliente" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="d-flex align-items-center mb-4">
        <div>
            <h2 class="mb-0">Canchas disponibles</h2>
            <small class="text-muted">
                <asp:Label ID="lblTotal" runat="server" />
            </small>
        </div>
    </div>

    <%-- Estado vacío global: sin canchas activas --%>
    <asp:Panel ID="pnlVacio" runat="server" Visible="false"
        CssClass="alert alert-info">
        No hay canchas disponibles por el momento.
    </asp:Panel>

    <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
        <asp:Repeater ID="rptCanchas" runat="server">
            <ItemTemplate>
                <div class="col">
                    <div class="card-r card-hover h-100">
                        <div class="card-r-pad d-flex flex-column">

                            <%-- Encabezado: ícono + nombre --%>
                            <div class="d-flex align-items-start gap-3 mb-3">
                                <asp:Panel runat="server" CssClass="sport-ico"
                                    Style='<%# "border-left: 3px solid " + GetDeporteAccent(Eval("Deporte.Nombre")) %>'>
                                    <asp:Label runat="server" Text='<%# GetDeporteEmoji(Eval("Deporte.Nombre")) %>' />
                                </asp:Panel>
                                <div class="flex-grow-1 min-w-0">
                                    <asp:Label runat="server" CssClass="mb-0 fw-semibold text-truncate d-block"
                                        Text='<%# Eval("NombreFantasia") %>' />
                                    <asp:Label runat="server" CssClass="text-soft small d-block"
                                        Text='<%# Eval("Deporte.Nombre") %>' />
                                </div>
                            </div>

                            <%-- Descripción --%>
                            <asp:Label runat="server" CssClass="text-soft small d-block mb-3"
                                Style="line-height:1.5" Text='<%# Eval("Descripcion") %>' />

                            <%-- Precio + capacidad --%>
                            <div class="d-flex justify-content-between align-items-center pt-2 mb-3" style="border-top: 1px solid var(--border-subtle)">
                                <asp:Label runat="server" CssClass="price-tag mt-2"
                                    Text='<%# FormatearPrecio(Eval("Precio")) %>' />
                                <asp:Label runat="server" CssClass="text-soft small mt-2"
                                    Text='<%# Eval("CapacidadJugadores") + " jugadores" %>' />
                            </div>

                            <%-- Franjas horarias --%>
                            <div class="mt-auto">
                                <asp:Label runat="server" CssClass="fw-semibold small d-block mb-1"
                                    Text="Horarios disponibles:" />

                                <%-- Mensaje cuando no hay franjas --%>
                                <asp:Panel ID="pnlSinHorarios" runat="server"
                                    CssClass="text-muted small fst-italic"
                                    Visible='<%# ((System.Collections.ICollection)Eval("Disponibilidades")).Count == 0 %>'>
                                    Sin horarios disponibles
                                </asp:Panel>

                                <%-- Sub-repeater de franjas --%>
                                <asp:Repeater ID="rptFranjas" runat="server"
                                    DataSource='<%# Eval("Disponibilidades") %>'>
                                    <ItemTemplate>
                                        <div class="d-flex justify-content-between small py-1 border-bottom border-light">
                                            <asp:Label runat="server" CssClass="fw-medium"
                                                Text='<%# NombreDia(Eval("DiaSemana")) %>' />
                                            <asp:Label runat="server" CssClass="text-muted"
                                                Text='<%# FormatearFranja(Eval("HoraApertura"), Eval("HoraCierre")) %>' />
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>

                                <%-- El cliente reserva esta cancha en el modal de Reservas, que llega
                                     con la cancha ya elegida solo si tiene horarios. --%>
                                <asp:HyperLink runat="server" CssClass="btn-r btn-primary-r w-100 mt-3"
                                    NavigateUrl='<%# "~/Reservas.aspx?cancha=" + Eval("IdCancha") %>'
                                    Visible='<%# ((System.Collections.ICollection)Eval("Disponibilidades")).Count > 0 %>'>
                                    Reservar turno
                                </asp:HyperLink>
                            </div>

                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>

</asp:Content>
