using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using System.Web;
using Dominio;
using Dominio.Enums;
using Negocio;

namespace WebApp
{
    public partial class Calendario : System.Web.UI.Page
    {
        // Tope de reservas que mostramos por celda antes de resumir el resto.
        private const int MaxEventosPorDia = 3;

        // Fecha de referencia. En modo Mes muestro el mes que la contiene,
        // en modo Semana, la semana que la contiene.
        private DateTime Ancla
        {
            get { return (DateTime)ViewState["ancla"]; }
            set { ViewState["ancla"] = value; }
        }

        private bool EsModoSemana
        {
            get { return (string)ViewState["modo"] == "semana"; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }
            if (u.Rol == RolUsuario.Cliente) { Response.Redirect("~/Dashboard.aspx"); return; }

            if (!IsPostBack)
            {
                ViewState["modo"] = "mes";
                Ancla = DateTime.Today;
                CargarCanchasFiltro();   
                CargarCalendario();
            }
        }

        private void CargarCalendario()
        {
            // El toggle refleja el modo activo, el resto lo arma cada vista.
            btnVistaMes.CssClass    = EsModoSemana ? "" : "active";
            btnVistaSemana.CssClass = EsModoSemana ? "active" : "";

            if (EsModoSemana) CargarSemana();
            else CargarMes();
        }

        private void CargarMes()
        {
            int año = Ancla.Year;
            int mes = Ancla.Month;

            CultureInfo ar = new CultureInfo("es-AR");
            string nombreMes = new DateTime(año, mes, 1).ToString("MMMM yyyy", ar);
            lblMesAno.Text = char.ToUpper(nombreMes[0]) + nombreMes.Substring(1);

            List<Reserva> reservas = AplicarFiltros(new NegocioReservas().ObtenerPorMes(año, mes));
            litCalendario.Text = GenerarCalendario(año, mes, reservas);
        }

        private void CargarSemana()
        {
            // La semana arranca el lunes. DayOfWeek trae Domingo=0, asi que corro el
            // indice para que Lunes=0 .. Domingo=6 y retrocedo hasta el lunes.
            int diasDesdeLunes = ((int)Ancla.DayOfWeek + 6) % 7;
            DateTime inicio = Ancla.Date.AddDays(-diasDesdeLunes);
            DateTime fin = inicio.AddDays(6);

            CultureInfo ar = new CultureInfo("es-AR");
            lblMesAno.Text = string.Format("{0} – {1}",
                inicio.ToString("d MMM", ar),
                fin.ToString("d MMM yyyy", ar));

            // ObtenerPorMes trae un mes completo, una semana puede cruzar dos meses,
            // asi que traigo los que toca y GenerarSemana filtra los 7 dias.
            List<Reserva> reservas = new NegocioReservas().ObtenerPorMes(inicio.Year, inicio.Month);
            if (fin.Month != inicio.Month)
                reservas.AddRange(new NegocioReservas().ObtenerPorMes(fin.Year, fin.Month));

            litCalendario.Text = GenerarSemana(inicio, AplicarFiltros(reservas));
        }

        // Carga las canchas del filtro desde la BBDD. Misma fuente y formato que Reservas.
        private void CargarCanchasFiltro()
        {
            ddlFiltroCancha.DataSource = new NegocioCanchas().ObtenerTodas();
            ddlFiltroCancha.DataValueField = "IdCancha";
            ddlFiltroCancha.DataTextField = "NombreFantasia";
            ddlFiltroCancha.DataBind();
            ddlFiltroCancha.Items.Insert(0, new System.Web.UI.WebControls.ListItem("Todas las canchas", "0"));
        }

        // Filtra por estado y cancha segun los combos. Mismo criterio que Reservas,
        // la cancha se compara por NombreFantasia.
        private List<Reserva> AplicarFiltros(List<Reserva> reservas)
        {
            if (ddlFiltroEstado.SelectedValue != "0")
            {
                int idEstado = int.Parse(ddlFiltroEstado.SelectedValue);
                reservas = reservas.FindAll(r => (int)r.Estado == idEstado);
            }

            if (ddlFiltroCancha.SelectedValue != "0")
            {
                string cancha = ddlFiltroCancha.SelectedItem.Text;
                reservas = reservas.FindAll(r => r.Cancha.NombreFantasia == cancha);
            }

            return reservas;
        }

        protected void Filtros_SelectedIndexChanged(object sender, EventArgs e)
        {
            CargarCalendario();
        }

        // Arrastra los filtros activos al drill-down para que Reservas abra con el
        // mismo recorte. Uso claves propias (festado/fcancha) para no pisar el
        // ?cancha= que usa el alta de reserva del cliente en Reservas.
        private string FiltrosParaUrl()
        {
            string q = "";
            if (ddlFiltroEstado.SelectedValue != "0")
                q += "&festado=" + ddlFiltroEstado.SelectedValue;
            if (ddlFiltroCancha.SelectedValue != "0")
                q += "&fcancha=" + ddlFiltroCancha.SelectedValue;
            return q;
        }

        // Texto del hover de un evento: Cliente · Cancha · Estado.
        // HtmlAttributeEncode porque va como valor del atributo title.
        private string TooltipReserva(Reserva r)
        {
            string txt = r.Cliente.Nombre + " " + r.Cliente.Apellido
                       + " · " + r.Cancha.NombreFantasia
                       + " · " + r.Estado;
            return HttpUtility.HtmlAttributeEncode(txt);
        }

        private string GenerarCalendario(int año, int mes, List<Reserva> reservas)
        {
            StringBuilder sb = new StringBuilder();
            DateTime primerDia = new DateTime(año, mes, 1);
            int diasEnMes = DateTime.DaysInMonth(año, mes);
            // Lunes como primer dia. DayOfWeek trae Domingo=0, lo corro a Lun=0 … Dom=6.
            int inicioCol = ((int)primerDia.DayOfWeek + 6) % 7;
            DateTime hoy = DateTime.Today;

            sb.Append("<div class='mcal-grid'>");

            foreach (string d in new[] { "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom" })
                sb.AppendFormat("<div class='mcal-dow'>{0}</div>", d);

            // Celdas vacías antes del primer día del mes
            for (int i = 0; i < inicioCol; i++)
                sb.Append("<div class='mcal-cell mcal-out'></div>");

            // Mismo recorte de filtros para todos los dias, lo calculo una sola vez.
            string filtros = FiltrosParaUrl();

            // Días del mes
            for (int dia = 1; dia <= diasEnMes; dia++)
            {
                DateTime fecha = new DateTime(año, mes, dia);
                bool esHoy = fecha == hoy;

                // Drill-down: el dia (y el "+N más") llevan a Reservas filtrado por esa
                // fecha mas los filtros activos.
                string urlDia = "Reservas.aspx?fecha=" + fecha.ToString("yyyy-MM-dd") + filtros;

                sb.AppendFormat("<div class='mcal-cell{0}'>", esHoy ? " mcal-today" : "");
                sb.AppendFormat("<a href='{0}' class='mcal-num{1}' title='Ver las reservas de este día'>{2}</a>",
                    urlDia, esHoy ? " is-today" : "", dia);

                // Un calendario mensual es una foto, no una lista. Reducimos la cantidad
                // a unos pocos eventos por dia y el resto lo resumimos en "+N mas".
                List<Reserva> delDia = reservas.FindAll(r2 => r2.Fecha.Date == fecha);
                int aMostrar = delDia.Count > MaxEventosPorDia ? MaxEventosPorDia : delDia.Count;

                for (int idx = 0; idx < aMostrar; idx++)
                {
                    Reserva r = delDia[idx];
                    string nombre = HttpUtility.HtmlEncode(r.Cliente.Nombre + " " + r.Cliente.Apellido);
                    // Clic en la franja: mismo dia filtrado y abre el detalle de esa reserva.
                    sb.AppendFormat("<a href='{0}&verReserva={1}' class='mcal-ev {2}' title='{3}'>{4} {5}</a>",
                        urlDia, r.IdReserva,
                        GetClaseEvento(r.Estado),
                        TooltipReserva(r),
                        r.HoraInicio.ToString(@"hh\:mm"),
                        nombre);
                }

                if (delDia.Count > MaxEventosPorDia)
                    sb.AppendFormat("<a href='{0}' class='mcal-more' title='Ver todas las reservas del día'>+{1} más</a>",
                        urlDia, delDia.Count - MaxEventosPorDia);

                sb.Append("</div>");
            }

            // Celdas vacías al final para completar la última fila
            int total = inicioCol + diasEnMes;
            int restantes = total % 7 == 0 ? 0 : 7 - (total % 7);
            for (int i = 0; i < restantes; i++)
                sb.Append("<div class='mcal-cell mcal-out'></div>");

            sb.Append("</div>");
            return sb.ToString();
        }

        private string GetClaseEvento(EstadoReserva estado)
        {
            switch (estado)
            {
                case EstadoReserva.Nueva:        return "mcal-nueva";
                case EstadoReserva.Reprogramada: return "mcal-reprogramada";
                case EstadoReserva.Cancelada:    return "mcal-cancelada";
                case EstadoReserva.Finalizada:   return "mcal-finalizada";
                default:                         return "mcal-noasistio";
            }
        }

        // Vista Semana: grilla de horas (filas) x 7 dias (columnas). Como los turnos
        // son bloques de 1 hora, cada celda es (dia, hora) y no hay solapamientos de
        // turnos cruzados. El rango de horas sale de las reservas de la semana.
        private string GenerarSemana(DateTime inicio, List<Reserva> reservas)
        {
            DateTime fin = inicio.AddDays(6);
            List<Reserva> sem = reservas.FindAll(r => r.Fecha.Date >= inicio && r.Fecha.Date <= fin);

            if (sem.Count == 0)
                return "<div class='wcal-empty'>No hay reservas para esta semana.</div>";

            int horaMin = 23, horaMax = 0;
            foreach (Reserva r in sem)
            {
                if (r.HoraInicio.Hours < horaMin) horaMin = r.HoraInicio.Hours;
                if (r.HoraInicio.Hours > horaMax) horaMax = r.HoraInicio.Hours;
            }

            StringBuilder sb = new StringBuilder();
            DateTime hoy = DateTime.Today;
            string[] diasSemana = { "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom" };
            string filtros = FiltrosParaUrl();

            sb.Append("<div class='wcal-grid'>");

            // Esquina vacia + cabecera de los 7 dias
            sb.Append("<div class='wcal-corner'></div>");
            for (int d = 0; d < 7; d++)
            {
                DateTime dia = inicio.AddDays(d);
                bool esHoy = dia == hoy;
                sb.AppendFormat("<div class='wcal-dayhead{0}'>{1} {2}</div>",
                    esHoy ? " is-today" : "", diasSemana[d], dia.Day);
            }

            // Una fila por hora. Adentro, una celda por dia con sus turnos.
            for (int h = horaMin; h <= horaMax; h++)
            {
                sb.AppendFormat("<div class='wcal-hour'>{0:00}:00</div>", h);
                for (int d = 0; d < 7; d++)
                {
                    DateTime dia = inicio.AddDays(d);
                    sb.Append("<div class='wcal-cell'>");
                    foreach (Reserva r in sem.FindAll(x => x.Fecha.Date == dia && x.HoraInicio.Hours == h))
                    {
                        string nombre = HttpUtility.HtmlEncode(r.Cliente.Nombre + " " + r.Cliente.Apellido);
                        string url = "Reservas.aspx?fecha=" + dia.ToString("yyyy-MM-dd") + filtros + "&verReserva=" + r.IdReserva;
                        sb.AppendFormat("<a href='{0}' class='mcal-ev {1}' title='{2}'>{3}</a>",
                            url, GetClaseEvento(r.Estado), TooltipReserva(r), nombre);
                    }
                    sb.Append("</div>");
                }
            }

            sb.Append("</div>");
            return sb.ToString();
        }

        protected void btnVistaMes_Click(object sender, EventArgs e)
        {
            ViewState["modo"] = "mes";
            CargarCalendario();
        }

        protected void btnVistaSemana_Click(object sender, EventArgs e)
        {
            ViewState["modo"] = "semana";
            CargarCalendario();
        }

        protected void btnAnterior_Click(object sender, EventArgs e)
        {
            Ancla = EsModoSemana ? Ancla.AddDays(-7) : Ancla.AddMonths(-1);
            CargarCalendario();
        }

        protected void btnSiguiente_Click(object sender, EventArgs e)
        {
            Ancla = EsModoSemana ? Ancla.AddDays(7) : Ancla.AddMonths(1);
            CargarCalendario();
        }

        protected void btnHoy_Click(object sender, EventArgs e)
        {
            Ancla = DateTime.Today;
            CargarCalendario();
        }
    }
}
