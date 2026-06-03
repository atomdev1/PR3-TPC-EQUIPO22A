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
        <button type="button" class="btn btn-success ms-auto"
            data-bs-toggle="modal" data-bs-target="#modalNuevaCancha">
            + Nueva cancha
        </button>
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

    <%-- Modal Nueva Cancha --%>
    <div class="modal fade" id="modalNuevaCancha" tabindex="-1" aria-labelledby="modalNuevaCanchaLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="modalNuevaCanchaLabel">Nueva cancha</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">

                        <div class="col-md-8">
                            <label class="form-label fw-semibold">Nombre de fantasía</label>
                            <asp:TextBox ID="txtNombre" runat="server" CssClass="form-control" placeholder="Ej: Cancha Tenis Central" MaxLength="100" />
                            <asp:RequiredFieldValidator ID="rfvNombre" runat="server"
                                ControlToValidate="txtNombre" ValidationGroup="NuevaCancha"
                                CssClass="text-danger small" ErrorMessage="El nombre es obligatorio." Display="Dynamic" />
                        </div>

                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Número</label>
                            <asp:TextBox ID="txtNumero" runat="server" CssClass="form-control" TextMode="Number" placeholder="1" />
                            <asp:RequiredFieldValidator ID="rfvNumero" runat="server"
                                ControlToValidate="txtNumero" ValidationGroup="NuevaCancha"
                                CssClass="text-danger small" ErrorMessage="El número es obligatorio." Display="Dynamic" />
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Deporte</label>
                            <asp:DropDownList ID="ddlDeporte" runat="server" CssClass="form-select" />
                            <asp:RequiredFieldValidator ID="rfvDeporte" runat="server"
                                ControlToValidate="ddlDeporte" InitialValue="0" ValidationGroup="NuevaCancha"
                                CssClass="text-danger small" ErrorMessage="Seleccioná un deporte." Display="Dynamic" />
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Capacidad de jugadores</label>
                            <asp:TextBox ID="txtCapacidad" runat="server" CssClass="form-control" TextMode="Number" placeholder="10" />
                            <asp:RequiredFieldValidator ID="rfvCapacidad" runat="server"
                                ControlToValidate="txtCapacidad" ValidationGroup="NuevaCancha"
                                CssClass="text-danger small" ErrorMessage="La capacidad es obligatoria." Display="Dynamic" />
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Precio por hora ($)</label>
                            <asp:TextBox ID="txtPrecio" runat="server" CssClass="form-control" TextMode="Number" placeholder="5000" />
                            <asp:RequiredFieldValidator ID="rfvPrecio" runat="server"
                                ControlToValidate="txtPrecio" ValidationGroup="NuevaCancha"
                                CssClass="text-danger small" ErrorMessage="El precio es obligatorio." Display="Dynamic" />
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Monto de seña ($)</label>
                            <asp:TextBox ID="txtSena" runat="server" CssClass="form-control" TextMode="Number" placeholder="2000" />
                            <asp:RequiredFieldValidator ID="rfvSena" runat="server"
                                ControlToValidate="txtSena" ValidationGroup="NuevaCancha"
                                CssClass="text-danger small" ErrorMessage="El monto de seña es obligatorio." Display="Dynamic" />
                        </div>

                        <div class="col-12">
                            <label class="form-label fw-semibold">Descripción</label>
                            <asp:TextBox ID="txtDescripcion" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"
                                placeholder="Ej: Césped sintético · Iluminación · Techada" MaxLength="300" />
                        </div>

                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <asp:Button ID="btnGuardarCancha" runat="server" Text="Guardar cancha"
                        CssClass="btn btn-success" OnClick="btnGuardarCancha_Click" ValidationGroup="NuevaCancha" />
                </div>
            </div>
        </div>
    </div>

</asp:Content>
