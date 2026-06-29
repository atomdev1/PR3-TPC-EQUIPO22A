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
                // Una sola lectura de reservas. La comparten el resumen (turnos de
                // hoy) y la tabla de ultimas reservas.
                List<Reserva> reservas = new NegocioReservas().Listar();
                CargarResumen(reservas);
                CargarUltimasReservas(reservas);
                CargarOcupacion();
                CargarClientesDeudores();
                CargarCanchasMenorUso();
            }
        }

        private void CargarInicioCliente()
        {
            Usuario u = (Usuario)Session["usuario"];
            lblBienvenida.Text = "¡Hola, " + u.Nombre + "! ¿Listo para jugar?";
        }


        private void CargarResumen(List<Reserva> reservas)
        {
            CultureInfo ar = new CultureInfo("es-AR");
            lblFecha.Text = DateTime.Today.ToString("dddd d 'de' MMMM 'de' yyyy", ar);

            lblCanchasActivas.Text = new NegocioCanchas().ObtenerTodas().Count(c => c.Activa).ToString();
            lblCuponesVigentes.Text = new NegocioCupones().ObtenerTodas().Count(c => c.Estado == EstadoCupon.Activo).ToString();

            // Turnos de hoy: reservas con fecha de hoy que no esten canceladas.
            lblTurnosHoy.Text = reservas
                .Count(r => r.Fecha.Date == DateTime.Today && r.Estado != EstadoReserva.Cancelada)
                .ToString();

            // Ingresos del dia: lo realmente cobrado hoy, segun la fecha de cada pago.
            lblIngresosHoy.Text = new NegocioPagos().ObtenerIngresosDelDia().ToString("C0", ar);
        }


        // Las ultimas reservas cargadas. Listar ya ordena por fecha descendente,
        // asi que las primeras son las mas recientes.
        private void CargarUltimasReservas(List<Reserva> reservas)
        {
            rptReservas.DataSource = reservas.Take(5).ToList();
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

        private void CargarClientesDeudores()
        {
            try
            {
                rptDeudores.DataSource = new NegocioReservas().ObtenerClientesDeudores();
                rptDeudores.DataBind();
            }
            catch
            {
                // Si la vista aún no existe, la tabla se muestra vacía
            }
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
            EstadoReserva estado = (EstadoReserva)estadoObj;
            switch (estado)
            {
                case EstadoReserva.Nueva:        return "badge fw-normal text-success bg-success-subtle";
                case EstadoReserva.Reprogramada: return "badge fw-normal text-warning bg-warning-subtle";
                case EstadoReserva.Cancelada:    return "badge fw-normal text-danger bg-danger-subtle";
                case EstadoReserva.Finalizada:   return "badge fw-normal text-primary bg-primary-subtle";
                default:                         return "badge fw-normal text-secondary bg-secondary-subtle";
            }
        }

        // Horario legible de una reserva para la tabla del Panel:
        // "Hoy 18:00", "Mañana 10:00" o la fecha corta si cae mas lejos.
        protected string FormatoHorarioReserva(object item)
        {
            Reserva r = (Reserva)item;
            string hora = r.HoraInicio.ToString(@"hh\:mm");
            if (r.Fecha.Date == DateTime.Today) return "Hoy " + hora;
            if (r.Fecha.Date == DateTime.Today.AddDays(1)) return "Mañana " + hora;
            if (r.Fecha.Date == DateTime.Today.AddDays(-1)) return "Ayer " + hora;
            return r.Fecha.ToString("dd/MM") + " " + hora;
        }
    }
}
