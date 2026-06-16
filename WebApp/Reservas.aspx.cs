using Dominio;
using Dominio.Enums;
using Negocio;
using System;
using System.Collections.Generic;
using System.Linq;

namespace WebApp
{
    public partial class Reservas : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }

            if (!IsPostBack)
                CargarReservas(u);
        }

        private void CargarReservas(Usuario u)
        {
            List<Reserva> lista = new NegocioReservas().Listar();

            if (u.Rol == RolUsuario.Cliente)
                lista = lista.Where(r => r.Cliente.IdUsuario == u.IdUsuario).ToList();

            rptReservas.DataSource = lista;
            rptReservas.DataBind();

            lblTotal.Text = lista.Count == 1
                ? "1 reserva"
                : lista.Count + " reservas";
        }

        protected string GetBadgeEstado(object estadoObj)
        {
            EstadoReserva estado = (EstadoReserva)estadoObj;
            switch (estado)
            {
                case EstadoReserva.Nueva: return "badge fw-normal text-primary bg-primary-subtle";
                case EstadoReserva.Reprogramada: return "badge fw-normal text-warning bg-warning-subtle";
                case EstadoReserva.Cancelada: return "badge fw-normal text-danger bg-danger-subtle";
                case EstadoReserva.Finalizada: return "badge fw-normal text-success bg-success-subtle";
                case EstadoReserva.NoAsistio: return "badge fw-normal text-secondary bg-secondary-subtle";
                default: return "badge fw-normal text-secondary bg-secondary-subtle";
            }
        }

        protected string GetBadgePago(object pagoObj)
        {
            EstadoPago pago = (EstadoPago)pagoObj;
            switch (pago)
            {
                case EstadoPago.Pagado: return "badge fw-normal text-success bg-success-subtle";
                case EstadoPago.Senado: return "badge fw-normal text-info bg-info-subtle";
                case EstadoPago.Pendiente: return "badge fw-normal text-warning bg-warning-subtle";
                default: return "badge fw-normal text-secondary bg-secondary-subtle";
            }
        }
    }
}