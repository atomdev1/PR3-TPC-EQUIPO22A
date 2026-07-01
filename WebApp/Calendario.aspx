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
            <%-- Toggle de vista Mes / Semana --%>
            <div class="seg">
                <asp:LinkButton ID="btnVistaMes" runat="server" OnClick="btnVistaMes_Click" Text="📅 Mes" />
                <asp:LinkButton ID="btnVistaSemana" runat="server" OnClick="btnVistaSemana_Click" Text="📆 Semana" />
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

    <%-- Filtros --%>
    <div class="card-r card-r-pad mb-3">
        <div class="row g-2 align-items-end">
            <div class="col-md-3">
                <label class="form-label small fw-semibold mb-1">Estado</label>
                <asp:DropDownList ID="ddlFiltroEstado" runat="server" CssClass="form-select form-select-sm"
                    AutoPostBack="true" OnSelectedIndexChanged="Filtros_SelectedIndexChanged">
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
                <asp:DropDownList ID="ddlFiltroCancha" runat="server" CssClass="form-select form-select-sm"
                    AutoPostBack="true" OnSelectedIndexChanged="Filtros_SelectedIndexChanged" />
            </div>
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