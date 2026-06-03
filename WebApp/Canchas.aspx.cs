using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using Dominio;

namespace WebApp
{
    public partial class Canchas : System.Web.UI.Page
    {
        protected Repeater rptCanchas;
        protected Label lblTotal;
        protected TextBox txtNombre;
        protected TextBox txtNumero;
        protected DropDownList ddlDeporte;
        protected TextBox txtCapacidad;
        protected TextBox txtPrecio;
        protected TextBox txtSena;
        protected TextBox txtDescripcion;
        protected Button btnGuardarCancha;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CargarCanchas();
                CargarDeportes();
            }
        }

        private void CargarCanchas()
        {
            List<Cancha> canchas = new List<Cancha>
            {
                new Cancha { IdCancha = 1, NombreFantasia = "Cancha Tenis Central", Precio = 6000, IdDeporte = 1, Deporte = new Deporte { IdDeporte = 1, Nombre = "Tenis", DuracionMinutos = 60 }, CapacidadJugadores = 4, Descripcion = "Polvo de ladrillo · Iluminación", Activa = true },
                new Cancha { IdCancha = 2, NombreFantasia = "Cancha Vóley Playa", Precio = 5000, IdDeporte = 4, Deporte = new Deporte { IdDeporte = 4, Nombre = "Voley", DuracionMinutos = 60 }, CapacidadJugadores = 12, Descripcion = "Arena", Activa = true },
                new Cancha { IdCancha = 3, NombreFantasia = "Cancha Pádel 1", Precio = 8000, IdDeporte = 2, Deporte = new Deporte { IdDeporte = 2, Nombre = "Pádel", DuracionMinutos = 60 }, CapacidadJugadores = 4, Descripcion = "Césped sintético · Techada", Activa = true },
                new Cancha { IdCancha = 4, NombreFantasia = "Cancha Fútbol 5 - A", Precio = 15000, IdDeporte = 3, Deporte = new Deporte { IdDeporte = 3, Nombre = "Fútbol", DuracionMinutos = 60 }, CapacidadJugadores = 10, Descripcion = "Césped sintético · Iluminación", Activa = true },
                new Cancha { IdCancha = 5, NombreFantasia = "Cancha Fútbol 5 - B", Precio = 15000, IdDeporte = 3, Deporte = new Deporte { IdDeporte = 3, Nombre = "Fútbol", DuracionMinutos = 60 }, CapacidadJugadores = 10, Descripcion = "Césped sintético", Activa = false },
                new Cancha { IdCancha = 6, NombreFantasia = "Cancha Básquet", Precio = 10000, IdDeporte = 5, Deporte = new Deporte { IdDeporte = 5, Nombre = "Básquet", DuracionMinutos = 60 }, CapacidadJugadores = 10, Descripcion = "Cemento · Techada · Iluminación", Activa = true },
            };

            rptCanchas.DataSource = canchas;
            rptCanchas.DataBind();

            lblTotal.Text = canchas.Count + " canchas registradas";
        }

        protected void rptCanchas_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int idCancha = int.Parse(e.CommandArgument.ToString());

            if (e.CommandName == "Editar")
            {
                Response.Redirect("EditarCancha.aspx?id=" + idCancha);
            }
            else if (e.CommandName == "Eliminar")
            {
                // HACER: llamar a la capa Negocio para "eliminar" (baja logica)
            }
        }

        private void CargarDeportes()
        {
            List<Deporte> deportes = new List<Deporte>
            {
                new Deporte { IdDeporte = 1, Nombre = "Tenis", DuracionMinutos = 60 },
                new Deporte { IdDeporte = 2, Nombre = "Pádel", DuracionMinutos = 60 },
                new Deporte { IdDeporte = 3, Nombre = "Fútbol", DuracionMinutos = 60 },
                new Deporte { IdDeporte = 4, Nombre = "Voley", DuracionMinutos = 60 },
                new Deporte { IdDeporte = 5, Nombre = "Básquet", DuracionMinutos = 60 },
            };

            ddlDeporte.DataSource = deportes;
            ddlDeporte.DataTextField = "Nombre";
            ddlDeporte.DataValueField = "IdDeporte";
            ddlDeporte.DataBind();
            ddlDeporte.Items.Insert(0, new ListItem("-- Seleccioná un deporte --", "0"));
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

        protected string FormatearPrecio(object precioObj)
        {
            return "$" + precioObj + " /hora";
        }

        protected string GetDeporteAccent(object nombreObj)
        {
            string nombre = (nombreObj ?? "").ToString().ToLower();
            if (nombre.Contains("fútbol") || nombre.Contains("futbol")) return "#2d6a4f";
            if (nombre.Contains("tenis")) return "#b5870a";
            if (nombre.Contains("básquet") || nombre.Contains("basquet")) return "#9b4d96";
            if (nombre.Contains("pádel") || nombre.Contains("padel")) return "#1a6fa8";
            if (nombre.Contains("vóley") || nombre.Contains("voley")) return "#c0392b";
            return "#4a5568";
        }

        protected void btnGuardarCancha_Click(object sender, EventArgs e)
        {
            Cancha cancha = new Cancha
            {
                NombreFantasia = txtNombre.Text.Trim(),
                Numero = int.Parse(txtNumero.Text),
                IdDeporte = int.Parse(ddlDeporte.SelectedValue),
                CapacidadJugadores = int.Parse(txtCapacidad.Text),
                Precio = decimal.Parse(txtPrecio.Text),
                MontoSena = decimal.Parse(txtSena.Text),
                Descripcion = txtDescripcion.Text.Trim(),
                Activa = true
            };

            // HACER: llamar a la capa Negocio para guardar la cancha
            Response.Redirect("Canchas.aspx");
        }
    }
}
