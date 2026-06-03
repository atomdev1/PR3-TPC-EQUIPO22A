<%@ Page Title="Canchas" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Canchas.aspx.cs" Inherits="WebApp.Canchas" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="d-flex align-items-center mb-4">
        <div>
            <h2 class="mb-0">Canchas</h2>
            <small class="text-muted">
                <asp:Label ID="lblTotal" runat="server" />
            </small>
        </div>
        <asp:Button ID="btnNuevaCancha" runat="server" Text="+ Nueva cancha"
            CssClass="btn btn-success ms-auto" OnClick="btnNuevaCancha_Click" />
    </div>

    <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
        <asp:Repeater ID="rptCanchas" runat="server" OnItemCommand="rptCanchas_ItemCommand">
            <ItemTemplate>
                <div class="col">
                    <div class="card h-100 shadow-sm">
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <h5 class="card-title mb-0"><%# Eval("NombreFantasia") %></h5>
                                <span class='badge <%# (bool)Eval("Activa") ? "bg-success" : "bg-warning text-dark" %>'>
                                    <%# (bool)Eval("Activa") ? "Disponible" : "En mantenimiento" %>
                                </span>
                            </div>
                            <p class="text-primary fw-bold mb-1">$<%# Eval("Precio") %>/h</p>
                            <p class="text-muted small mb-1"><%# Eval("Deporte.Nombre") %></p>
                            <p class="card-text small mb-2"><%# Eval("Descripcion") %></p>
                            <p class="small text-secondary mb-3">
                                <i class="bi bi-people"></i> <%# Eval("CapacidadJugadores") %> jugadores
                            </p>
                            <div class="d-flex gap-2">
                                <asp:LinkButton ID="btnEditar" runat="server"
                                    CommandName="Editar"
                                    CommandArgument='<%# Eval("IdCancha") %>'
                                    CssClass="btn btn-sm btn-outline-primary w-100">
                                    Editar
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnEliminar" runat="server"
                                    CommandName="Eliminar"
                                    CommandArgument='<%# Eval("IdCancha") %>'
                                    CssClass="btn btn-sm btn-outline-danger"
                                    OnClientClick="return confirm('¿Eliminar esta cancha?');">
                                    Eliminar
                                </asp:LinkButton>
                            </div>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>

</asp:Content>
