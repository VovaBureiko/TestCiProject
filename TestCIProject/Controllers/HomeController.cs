using Microsoft.AspNetCore.Mvc;

namespace TestCIProject.Controllers
{
    public class HomeController : Controller
    {
        public IActionResult Index(string word = "word")
        {
            ViewBag.Word = word;
            return View();
        }
    }
}