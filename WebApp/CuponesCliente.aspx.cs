using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;
using Dominio;
using Dominio.Enums;
using Negocio;

namespace WebApp
{
    public partial class CuponesCliente : CuponPageBase
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }
            if (u.Rol != RolUsuario.Cliente) { Response.Redirect("~/Dashboard.aspx"); return; }

            if (!IsPostBack){
                CargarCupones();
            }
        }

        // Reservas acumuladas del cliente logueado. La usan los helpers de progreso
        // del Repeater de objetivos para preguntarle a cada beneficio "¿cuánto falta?".
        protected int reservasCliente;

        private void CargarCupones()
        {
            Usuario usuario = (Usuario)Session["usuario"];
            reservasCliente = usuario.CantidadAsistencias;

            List<Cupon> cupones = new NegocioCupones().ObtenerPorUsuario(usuario.IdUsuario);

            // Usables ahora vs historial (canjeados / vencidos / agotados)
            List<Cupon> disponibles = cupones.Where(c => c.Estado == EstadoCupon.Activo).ToList();
            List<Cupon> historial = cupones.Where(c => c.Estado != EstadoCupon.Activo).ToList();

            rptDisponibles.DataSource = disponibles;
            rptDisponibles.DataBind();
            rptHistorial.DataSource = historial;
            rptHistorial.DataBind();

            // Objetivos "en camino": beneficios del catálogo que el cliente todavía no alcanzó.
            // El cupón real recién existe cuando el trigger lo genere al llegar al umbral.
            List<BeneficioFidelidad> objetivos = new NegocioBeneficios()
                .ObtenerActivos()
                .Where(b => !b.YaAlcanzado(reservasCliente))
                .ToList();

            rptObjetivos.DataSource = objetivos;
            rptObjetivos.DataBind();

            pnlVacio.Visible = cupones.Count == 0 && objetivos.Count == 0;
            pnlDisponibles.Visible = cupones.Count > 0;
            pnlSinDisponibles.Visible = cupones.Count > 0 && disponibles.Count == 0;
            pnlHistorial.Visible = historial.Count > 0;
            pnlObjetivos.Visible = objetivos.Count > 0;

            lblTotal.Text = disponibles.Count == 1
                ? "1 cupón disponible"
                : disponibles.Count + " cupones disponibles";
        }

        // Helpers del Repeater de objetivos: delegan en el comportamiento del dominio

        protected string TextoFaltantes(object beneficioObj)
        {
            int faltan = ((BeneficioFidelidad)beneficioObj).ReservasFaltantes(reservasCliente);
            return faltan == 1
                ? "Te falta 1 reserva"
                : "Te faltan " + faltan + " reservas";
        }

        protected int ProgresoPorcentaje(object beneficioObj)
        {
            return ((BeneficioFidelidad)beneficioObj).PorcentajeProgreso(reservasCliente);
        }

        protected string ProgresoFraccion(object beneficioObj)
        {
            return reservasCliente + " / " + ((BeneficioFidelidad)beneficioObj).ReservasRequeridas;
        }

        // Los helpers de presentación de cupones (badge, tipo, estado, valor, meta)
        // estan en CuponPageBase, compartidos con la pantalla de admin.
    }
}
