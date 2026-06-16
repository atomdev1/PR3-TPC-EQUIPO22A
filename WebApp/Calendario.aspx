<%@ Page Title="Calendario" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Calendario.aspx.cs" Inherits="WebApp.Calendario" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Encabezado --%>
    <div class="d-flex align-items-center mb-3 flex-wrap gap-2">
        <div>
            <h2 class="mb-0">Calendario</h2>
            <small class="text-muted">
                <asp:Label ID="lblMesAno" runat="server" />
            </small>
        </div>
        <div class="ms-auto d-flex align-items-center gap-2">
            <%-- Toggle de vista (Por cancha pendiente) --%>
            <div class="seg">
                <button type="button" class="active" disabled>📅 Mes</button>
                <button type="button" disabled title="Próximamente">⊞ Por cancha</button>
            </div>
            <%-- Navegación --%>
            <asp:LinkButton ID="btnAnterior" runat="server" OnClick="btnAnterior_Click"
                CssClass="btn-r btn-sm-r btn-ghost-r" Text="&#8249;" />
            <asp:LinkButton ID="btnHoy" runat="server" OnClick="btnHoy_Click"
                CssClass="btn-r btn-sm-r btn-ghost-r" Text="Hoy" />
            <asp:LinkButton ID="btnSiguiente" runat="server" OnClick="btnSiguiente_Click"
                CssClass="btn-r btn-sm-r btn-ghost-r" Text="&#8250;" />
        </div>
    </div>

    <%-- Grid del calendario --%>
    <div class="card-r">
        <div class="p-3">
            <asp:Literal ID="litCalendario" runat="server" />
        </div>
    </div>

    <%-- Leyenda --%>
    <div class="d-flex flex-wrap gap-4 mt-3 ps-1 small text-muted">
        <span><span class="mcal-dot mcal-nueva"></span> Nueva</span>
        <span><span class="mcal-dot mcal-reprogramada"></span> Reprogramada</span>
        <span><span class="mcal-dot mcal-cancelada"></span> Cancelada</span>
        <span><span class="mcal-dot mcal-finalizada"></span> Finalizada</span>
        <span><span class="mcal-dot mcal-noasistio"></span> No asistió</span>
    </div>

</asp:Content>