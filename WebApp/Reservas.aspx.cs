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
        protected bool EsCliente { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }

            EsCliente = u.Rol == RolUsuario.Cliente;

            if (!IsPostBack)
            {
                CargarCanchasFiltro();
                CargarReservas(u);
            }
        }

        // Llena el combo de canchas del filtro con datos de la BD.
        private void CargarCanchasFiltro()
        {
            ddlFiltroCancha.DataSource = new NegocioCanchas().ObtenerTodas();
            ddlFiltroCancha.DataValueField = "IdCancha";
            ddlFiltroCancha.DataTextField = "NombreFantasia";
            ddlFiltroCancha.DataBind();
            ddlFiltroCancha.Items.Insert(0, new System.Web.UI.WebControls.ListItem("Todas las canchas", "0"));
        }

        private void CargarReservas(Usuario u)
        {
            List<Reserva> lista = new NegocioReservas().Listar();

            if (u.Rol == RolUsuario.Cliente)
                lista = lista.Where(r => r.Cliente.IdUsuario == u.IdUsuario).ToList();

            // Filtros (todos opcionales): estado, cancha y fecha.
            if (ddlFiltroEstado.SelectedValue != "0")
            {
                int idEstado = int.Parse(ddlFiltroEstado.SelectedValue);
                lista = lista.Where(r => (int)r.Estado == idEstado).ToList();
            }

            if (ddlFiltroCancha.SelectedValue != "0")
            {
                string cancha = ddlFiltroCancha.SelectedItem.Text;
                lista = lista.Where(r => r.Cancha.NombreFantasia == cancha).ToList();
            }

            DateTime fecha;
            if (DateTime.TryParse(txtFiltroFecha.Text, out fecha))
                lista = lista.Where(r => r.Fecha.Date == fecha.Date).ToList();

            rptReservas.DataSource = lista;
            rptReservas.DataBind();

            lblTotal.Text = lista.Count == 1
                ? "1 reserva"
                : lista.Count + " reservas";
        }

        protected void btnFiltrar_Click(object sender, EventArgs e)
        {
            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }
            CargarReservas(u);
        }

        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }

            ddlFiltroEstado.SelectedValue = "0";
            ddlFiltroCancha.SelectedValue = "0";
            txtFiltroFecha.Text = "";
            CargarReservas(u);
        }

        // Botones de fila de la grilla. Por ahora solo implemento "RegistrarPago", que abre
        // el modal cargado con el saldo de la reserva.
        protected void rptReservas_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Ver")
            {
                int idReserva = int.Parse(e.CommandArgument.ToString());
                Reserva r = new NegocioReservas().Listar()
                    .FirstOrDefault(x => x.IdReserva == idReserva);
                if (r == null) return;

                lblDetCliente.Text = r.Cliente.Nombre + " " + r.Cliente.Apellido;
                lblDetCancha.Text  = r.Cancha.NombreFantasia + " · " + r.Cancha.Deporte.Nombre;
                lblDetFecha.Text   = r.Fecha.ToString("dd/MM/yyyy");
                lblDetHorario.Text = r.HoraInicio.ToString(@"hh\:mm") + " – " + r.HoraFin.ToString(@"hh\:mm");
                lblDetPrecio.Text  = string.Format("{0:C0}", r.PrecioTotal);
                lblDetEstado.Text  = r.Estado.ToString();
                lblDetPago.Text    = GetTextoPago(r.EstadoPago);
                lblDetObs.Text     = string.IsNullOrEmpty(r.Observaciones) ? "Sin observaciones" : r.Observaciones;

                AbrirModalDetalle();
            }
            else if (e.CommandName == "RegistrarPago")
            {
                int idReserva = int.Parse(e.CommandArgument.ToString());

                // Busco precio total y lo ya pagado para mostrar el saldo y
                // proponer ese monto por defecto.
                Reserva reserva = new NegocioReservas().Listar()
                    .FirstOrDefault(r => r.IdReserva == idReserva);
                if (reserva == null) return;

                decimal pagado = new NegocioPagos().ObtenerTotalPagado(idReserva);
                decimal saldo = reserva.PrecioTotal - pagado;
                if (saldo < 0) saldo = 0;

                hfIdReservaPago.Value = idReserva.ToString();
                lblPagoReserva.Text   = "Reserva #" + idReserva;
                lblPagoPrecio.Text    = string.Format("{0:C0}", reserva.PrecioTotal);
                lblPagoPagado.Text    = string.Format("{0:C0}", pagado);
                lblPagoSaldo.Text     = string.Format("{0:C0}", saldo);
                txtMontoPago.Text     = saldo.ToString("0.##");
                ddlFormaPago.SelectedValue = "1";
                lblErrorPago.Visible  = false;

                AbrirModalPago();
            }
        }

        // Confirma el pago: inserta en Pagos y el trigger recalcula el estado.
        protected void btnConfirmarPago_Click(object sender, EventArgs e)
        {
            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }

            decimal monto;
            if (!decimal.TryParse(txtMontoPago.Text, out monto) || monto <= 0)
            {
                lblErrorPago.Text = "Ingresá un monto válido mayor a cero.";
                lblErrorPago.Visible = true;
                AbrirModalPago();
                return;
            }

            Pago pago = new Pago
            {
                Monto = monto,
                FormaDePago = (FormaPago)int.Parse(ddlFormaPago.SelectedValue)
            };

            new NegocioPagos().RegistrarPago(pago, int.Parse(hfIdReservaPago.Value));

            // Recargo la grilla: el badge de pago ya viene actualizado por el trigger.
            CargarReservas(u);
        }

        private void AbrirModalPago()
        {
            string script =
                "bootstrap.Modal.getOrCreateInstance(document.getElementById('modalRegistrarPago')).show();";
            ClientScript.RegisterStartupScript(GetType(), "abrirModalPago", script, true);
        }

        private void AbrirModalDetalle()
        {
            string script =
                "bootstrap.Modal.getOrCreateInstance(document.getElementById('modalDetalleReserva')).show();";
            ClientScript.RegisterStartupScript(GetType(), "abrirModalDetalle", script, true);
        }

        protected string GetBadgeEstado(object estadoObj)
        {
            EstadoReserva estado = (EstadoReserva)estadoObj;
            switch (estado)
            {
                case EstadoReserva.Nueva:        return "tag tag-ok";
                case EstadoReserva.Reprogramada: return "tag tag-warn";
                case EstadoReserva.Cancelada:    return "tag tag-danger";
                case EstadoReserva.Finalizada:   return "tag tag-info";
                case EstadoReserva.NoAsistio:    return "tag tag-neutral";
                default:                         return "tag tag-neutral";
            }
        }

        protected string GetBadgePago(object pagoObj)
        {
            EstadoPago pago = (EstadoPago)pagoObj;
            switch (pago)
            {
                case EstadoPago.Pagado:      return "tag tag-ok";
                case EstadoPago.Senado:      return "tag tag-info";
                case EstadoPago.Pendiente:   return "tag tag-warn";
                case EstadoPago.Reembolsado: return "tag tag-neutral";
                default:                     return "tag tag-neutral";
            }
        }

        // Texto que ve el usuario. El nombre del enum (Senado) no lleva ñ a
        // propósito: los acentos van en la capa de presentación, no en el identificador.
        protected string GetTextoPago(object pagoObj)
        {
            EstadoPago pago = (EstadoPago)pagoObj;
            switch (pago)
            {
                case EstadoPago.Senado:      return "Señado";
                default:                     return pago.ToString();
            }
        }
    }
}