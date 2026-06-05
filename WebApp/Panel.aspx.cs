using System;
using System.Collections.Generic;
using System.Globalization;
using System.Web.UI.WebControls;

namespace WebApp
{
    public partial class Panel : System.Web.UI.Page
    {
        protected Label lblFecha;
        protected Label lblTurnosHoy;
        protected Label lblCanchasActivas;
        protected Label lblCuponesVigentes;
        protected Label lblIngresosHoy;
        protected Repeater rptReservas;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CargarResumen();
                CargarUltimasReservas();
            }
        }

        // NOTA: datos de demostración hardcodeados. Todavía no hay conexión a la BBDD.
        private void CargarResumen()
        {
            CultureInfo ar = new CultureInfo("es-AR");

            lblFecha.Text = DateTime.Today.ToString("dddd d 'de' MMMM 'de' yyyy", ar);
            lblTurnosHoy.Text = "12";
            lblCanchasActivas.Text = "8";
            lblCuponesVigentes.Text = "5";
            lblIngresosHoy.Text = (48500m).ToString("C0", ar);
        }

        // NOTA: datos de demostración hardcodeados. Todavía no hay conexión a la BBDD.
        private void CargarUltimasReservas()
        {
            List<ReservaDemo> reservas = new List<ReservaDemo>
            {
                new ReservaDemo { Cliente = "Lucía Fernández", Cancha = "Cancha Tenis Central", Deporte = "Tenis",  Horario = "Hoy 18:00", Estado = "Confirmada" },
                new ReservaDemo { Cliente = "Martín Gómez",    Cancha = "Fútbol 5 - Norte",    Deporte = "Fútbol", Horario = "Hoy 19:00", Estado = "Pendiente" },
                new ReservaDemo { Cliente = "Sofía Ramírez",   Cancha = "Pádel 1",             Deporte = "Pádel",  Horario = "Hoy 20:00", Estado = "Confirmada" },
                new ReservaDemo { Cliente = "Diego Sosa",      Cancha = "Básquet Techada",     Deporte = "Básquet",Horario = "Hoy 21:00", Estado = "Cancelada" },
                new ReservaDemo { Cliente = "Camila Torres",   Cancha = "Fútbol 5 - Sur",      Deporte = "Fútbol", Horario = "Mañana 10:00", Estado = "Pendiente" },
            };

            rptReservas.DataSource = reservas;
            rptReservas.DataBind();
        }

        protected string GetDeporteEmoji(object nombreObj)
        {
            string nombre = (nombreObj ?? "").ToString().ToLower();
            if (nombre.Contains("fútbol") || nombre.Contains("futbol")) return "⚽";
            if (nombre.Contains("tenis")) return "🎾";
            if (nombre.Contains("básquet") || nombre.Contains("basquet")) return "🏀";
            if (nombre.Contains("pádel") || nombre.Contains("padel")) return "🏓";
            if (nombre.Contains("vóley") || nombre.Contains("voley")) return "🏐";
            return "🏟️";
        }

        protected string GetEstadoBadge(object estadoObj)
        {
            string estado = (estadoObj ?? "").ToString().ToLower();
            if (estado == "confirmada") return "badge fw-normal text-success bg-success-subtle";
            if (estado == "pendiente") return "badge fw-normal text-warning bg-warning-subtle";
            if (estado == "cancelada") return "badge fw-normal text-danger bg-danger-subtle";
            return "badge fw-normal text-secondary bg-secondary-subtle";
        }
    }

    // solo para la vista del Panel (datos de demo, sin BBDD).
    public class ReservaDemo
    {
        public string Cliente { get; set; }
        public string Cancha { get; set; }
        public string Deporte { get; set; }
        public string Horario { get; set; }
        public string Estado { get; set; }
    }
}
