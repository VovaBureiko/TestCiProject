using System;
using System.Collections.Generic;
using System.Text;
using TestCIProject.Controllers;
using Microsoft.AspNetCore.Mvc;
using Xunit;

namespace TestCIProject.Tests.Controllers
{
    public class HomeControllerTest
    {
        private readonly HomeController _controller;

        public HomeControllerTest()
        {
            _controller = new HomeController();
        }

        [Fact]
        public void String_Index_ViebagWithString()
        {
            // Arrange
            var word = "anotherWord";

            // Act
            _controller.Index(word);

            // Assert

            Assert.Equal(word, _controller.ViewBag.word);
        }
    }
}
