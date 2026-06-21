using Dominio;
using Dominio.Enums;
using Negocio;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI.WebControls;

namespace WebApp
{
    public partial class Dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }

            if (!IsPostBack)
            {
                MostrarSegunRol(u.Rol);
            }
        }

        private void MostrarSegunRol(RolUsuario rol)
        {
            bool esCliente = rol == RolUsuario.Cliente;

            pnlStaff.Visible = !esCliente;
            pnlCliente.Visible = esCliente;

            if (esCliente)
                CargarInicioCliente();
            else
            {
                CargarResumen();
                CargarUltimasReservas();
                CargarOcupacion();
                CargarCanchasMenorUso();
            }
        }

        private void CargarInicioCliente()
        {
            Usuario u = (Usuario)Session["usuario"];
            lblBienvenida.Text = "¡Hola, " + u.Nombre + "! ¿Listo para jugar?";
        }


        // NOTA: datos de demostración hardcodeados. Todavía no hay conexión a la BBDD.
        private void CargarResumen()
        {
            CultureInfo ar = new CultureInfo("es-AR");
            lblFecha.Text = DateTime.Today.ToString("dddd d 'de' MMMM 'de' yyyy", ar);
            
            lblCanchasActivas.Text = new NegocioCanchas().ObtenerTodas().Count(c => c.Activa).ToString();
            lblCuponesVigentes.Text = new NegocioCupones().ObtenerTodas().Count(c => c.Estado == EstadoCupon.Activo).ToString();


            // PENDIENTE HASTA IMPLEMENTAR NegocioReservas.cs
            lblTurnosHoy.Text = "12";
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

        // Mapa de calor de ocupación: 3 turnos (filas) x 7 días (columnas).
        private void CargarOcupacion()
        {
            List<OcupacionTurno> datos;
            try { datos = new NegocioReservas().ObtenerOcupacionPorTurno(); }
            catch { datos = new List<OcupacionTurno>(); }   // si la vista aún no se creó, la grilla se muestra en cero
            litHeatmap.Text = GenerarHeatmap(datos);
        }
        private void CargarCanchasMenorUso()
        {
            List<CanchaMenorUso> lista = new NegocioReservas().ObtenerCanchasMenorUso();

            rptCanchasMenorUso.DataSource = lista;
            rptCanchasMenorUso.DataBind();

            pnlSinCanchasMenorUso.Visible = lista.Count == 0;
        }
        private string GenerarHeatmap(List<OcupacionTurno> datos)
        {
            string[] diasCorto = { "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom" };
            string[] diasLargo = { "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo" };
            string[] turnos    = { "Mañana", "Tarde", "Noche" };
            CultureInfo inv = CultureInfo.InvariantCulture;

            // El color va por volumen relativo a la celda más concurrida.
            int maxCant = datos.Count == 0 ? 0 : datos.Max(o => o.CantidadReservas);

            StringBuilder sb = new StringBuilder();
            sb.Append("<div class='heat-grid'>");

            // Encabezado: esquina vacía + nombres de los días
            sb.Append("<div class='heat-corner'></div>");
            for (int d = 0; d < 7; d++)
                sb.AppendFormat("<div class='heat-dow'>{0}</div>", diasCorto[d]);

            // Una fila por turno (1=Mañana 2=Tarde 3=Noche)
            for (int t = 1; t <= 3; t++)
            {
                sb.AppendFormat("<div class='heat-turno'>{0}</div>", turnos[t - 1]);
                for (int d = 0; d < 7; d++)
                {
                    OcupacionTurno celda = datos.Find(o => o.DiaNum == d && o.TurnoOrden == t);
                    int cant = celda == null ? 0 : celda.CantidadReservas;
                    decimal pct = celda == null ? 0m : celda.PorcentajeOcupacion;

                    sb.AppendFormat(
                        "<div class='heat-cell {0}' title='{1} · {2}: {3} reservas ({4}% ocupación)'>" +
                            "<span class='heat-cant'>{3}</span>" +
                            "<span class='heat-pct'>{4}%</span>" +
                        "</div>",
                        GetHeatClase(cant, maxCant),
                        HttpUtility.HtmlEncode(diasLargo[d]),
                        HttpUtility.HtmlEncode(turnos[t - 1]),
                        cant,
                        pct.ToString("0.#", inv));
                }
            }

            sb.Append("</div>");
            return sb.ToString();
        }

        // Tramo de color por volumen. Sin reservas queda neutro.
        private string GetHeatClase(int cant, int maxCant)
        {
            if (cant == 0 || maxCant == 0) return "heat-0";
            double r = (double)cant / maxCant;
            if (r <= 0.20) return "heat-1";
            if (r <= 0.40) return "heat-2";
            if (r <= 0.60) return "heat-3";
            if (r <= 0.80) return "heat-4";
            return "heat-5";
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
