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
        protected void Page_Load(object sender, EventArgs e)
        {
            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }
            if (u.Rol == RolUsuario.Cliente) { Response.Redirect("~/Dashboard.aspx"); return; }

            if (!IsPostBack)
            {
                ViewState["año"] = DateTime.Today.Year;
                ViewState["mes"] = DateTime.Today.Month;
                CargarCalendario();
            }
        }

        private void CargarCalendario()
        {
            int año = (int)ViewState["año"];
            int mes  = (int)ViewState["mes"];

            CultureInfo ar = new CultureInfo("es-AR");
            string nombreMes = new DateTime(año, mes, 1).ToString("MMMM yyyy", ar);
            lblMesAno.Text = char.ToUpper(nombreMes[0]) + nombreMes.Substring(1);

            List<Reserva> reservas = new NegocioReservas().ObtenerPorMes(año, mes);
            litCalendario.Text = GenerarCalendario(año, mes, reservas);
        }

        private string GenerarCalendario(int año, int mes, List<Reserva> reservas)
        {
            StringBuilder sb = new StringBuilder();
            DateTime primerDia = new DateTime(año, mes, 1);
            int diasEnMes = DateTime.DaysInMonth(año, mes);
            int inicioCol = (int)primerDia.DayOfWeek; // Dom=0 … Sáb=6
            DateTime hoy = DateTime.Today;

            sb.Append("<div class='mcal-grid'>");

            foreach (string d in new[] { "Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb" })
                sb.AppendFormat("<div class='mcal-dow'>{0}</div>", d);

            // Celdas vacías antes del primer día del mes
            for (int i = 0; i < inicioCol; i++)
                sb.Append("<div class='mcal-cell mcal-out'></div>");

            // Días del mes
            for (int dia = 1; dia <= diasEnMes; dia++)
            {
                DateTime fecha = new DateTime(año, mes, dia);
                bool esHoy = fecha == hoy;

                sb.AppendFormat("<div class='mcal-cell{0}'>", esHoy ? " mcal-today" : "");
                sb.AppendFormat("<div class='mcal-num{0}'>{1}</div>",
                    esHoy ? " is-today" : "", dia);

                foreach (Reserva r in reservas.FindAll(r2 => r2.Fecha.Date == fecha))
                {
                    string nombre = HttpUtility.HtmlEncode(r.Cliente.Nombre + " " + r.Cliente.Apellido);
                    sb.AppendFormat("<div class='mcal-ev {0}'>{1} {2}</div>",
                        GetClaseEvento(r.Estado),
                        r.HoraInicio.ToString(@"H\:mm"),
                        nombre);
                }

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

        protected void btnAnterior_Click(object sender, EventArgs e)
        {
            DateTime dt = new DateTime((int)ViewState["año"], (int)ViewState["mes"], 1).AddMonths(-1);
            ViewState["año"] = dt.Year;
            ViewState["mes"] = dt.Month;
            CargarCalendario();
        }

        protected void btnSiguiente_Click(object sender, EventArgs e)
        {
            DateTime dt = new DateTime((int)ViewState["año"], (int)ViewState["mes"], 1).AddMonths(1);
            ViewState["año"] = dt.Year;
            ViewState["mes"] = dt.Month;
            CargarCalendario();
        }

        protected void btnHoy_Click(object sender, EventArgs e)
        {
            ViewState["año"] = DateTime.Today.Year;
            ViewState["mes"] = DateTime.Today.Month;
            CargarCalendario();
        }
    }
}
