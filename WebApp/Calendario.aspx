<%@ Page Title="Calendario" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Calendario.aspx.cs" Inherits="WebApp.Calendario" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    .cal-tabla          { table-layout: fixed; width: 100%; }
    .cal-th             { text-align: center; font-size: .75rem; text-transform: uppercase;
                          letter-spacing: .05em; color: #6c757d; padding: 8px 4px; }
    .cal-celda          { vertical-align: top; padding: 6px 8px; height: 115px; }
    .cal-fuera-mes      { background: #f8f9fa; }
    .cal-dia-hoy        { box-shadow: inset 0 0 0 2px #2d6a4f; }
    .cal-num            { display: inline-flex; align-items: center; justify-content: center;
                          width: 26px; height: 26px; font-size: .85rem; font-weight: 500;
                          border-radius: 50%; margin-bottom: 3px; }
    .cal-num-hoy        { background: #2d6a4f; color: #fff !important; }
    .cal-evento         { font-size: .72rem; padding: 2px 7px; border-radius: 10px;
                          margin-bottom: 2px; white-space: nowrap; overflow: hidden;
                          text-overflow: ellipsis; color: #fff; font-weight: 500; }
    .cal-nueva          { background: #2d6a4f; }
    .cal-reprogramada   { background: #e9a835; }
    .cal-cancelada      { background: #dc3545; }
    .cal-finalizada     { background: #1a6fa8; }
    .cal-noasistio      { background: #6c757d; }
    .cal-punto          { display: inline-block; width: 9px; height: 9px;
                          border-radius: 50%; margin-right: 4px; vertical-align: middle; }
</style>
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
            <div class="btn-group btn-group-sm" role="group">
                <button type="button" class="btn btn-outline-secondary active" disabled>📅 Mes</button>
                <button type="button" class="btn btn-outline-secondary" disabled title="Próximamente">⊞ Por cancha</button>
            </div>
            <%-- Navegación --%>
            <asp:LinkButton ID="btnAnterior" runat="server" OnClick="btnAnterior_Click"
                CssClass="btn btn-sm btn-outline-secondary" Text="&#8249;" />
            <asp:LinkButton ID="btnHoy" runat="server" OnClick="btnHoy_Click"
                CssClass="btn btn-sm btn-outline-secondary" Text="Hoy" />
            <asp:LinkButton ID="btnSiguiente" runat="server" OnClick="btnSiguiente_Click"
                CssClass="btn btn-sm btn-outline-secondary" Text="&#8250;" />
        </div>
    </div>

    <%-- Grid del calendario --%>
    <div class="card app-card">
        <div class="card-body p-0">
            <asp:Literal ID="litCalendario" runat="server" />
        </div>
    </div>

    <%-- Leyenda --%>
    <div class="d-flex flex-wrap gap-4 mt-3 ps-1 small text-muted">
        <span><span class="cal-punto" style="background:#2d6a4f;"></span>Nueva</span>
        <span><span class="cal-punto" style="background:#e9a835;"></span>Reprogramada</span>
        <span><span class="cal-punto" style="background:#dc3545;"></span>Cancelada</span>
        <span><span class="cal-punto" style="background:#1a6fa8;"></span>Finalizada</span>
        <span><span class="cal-punto" style="background:#6c757d;"></span>No asistió</span>
    </div>

</asp:Content>